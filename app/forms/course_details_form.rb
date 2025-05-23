# frozen_string_literal: true

class CourseDetailsForm < TraineeForm
  include CourseFormHelpers
  include DatesHelper

  FIELDS = %i[
    course_uuid
    course_subject_one
    course_subject_one_raw
    course_subject_two
    course_subject_two_raw
    course_subject_three
    course_subject_three_raw
    course_allocation_subject
    start_day
    start_month
    start_year
    end_day
    end_month
    end_year
    main_age_range
    additional_age_range
    study_mode
    primary_course_subjects
    training_route
  ].freeze

  COURSE_DATES = %i[
    start_day
    start_month
    start_year
    end_day
    end_month
    end_year
  ].freeze

  attr_accessor(*FIELDS)

  before_validation :sanitise_course_dates
  before_validation :sanitise_subjects

  validates :course_subject_one, autocomplete: true, presence: true, if: :requires_secondary_subjects?
  validate :primary_courses_valid, if: :requires_primary_subjects?

  validate :course_subject_two_valid, if: :require_subject?
  validates :course_subject_two, autocomplete: true, if: :require_subject?

  validate :course_subject_three_valid, if: :require_subject?
  validates :course_subject_three, autocomplete: true, if: :require_subject?

  validate :age_range_valid, if: :require_age_range?
  validates :additional_age_range, presence: true, if: -> { other_age_range? && require_age_range? }

  validates :study_mode, inclusion: { in: TRAINEE_STUDY_MODE_ENUMS.keys }, if: :requires_study_mode?

  validate :itt_start_date_valid
  validate :itt_end_date_valid

  delegate :apply_application?, :requires_study_mode?, to: :trainee
  delegate :training_route, to: :training_routes_form

  MAX_END_YEARS = 4

  def initialize(...)
    super
    @primary_course_subjects ||= set_primary_phase_subjects if is_primary_phase?
    @training_routes_form = TrainingRoutesForm.new(trainee)
    @course_allocation_subject ||= set_early_years_attributes if early_years_route?
  end

  def early_years_route?
    EARLY_YEARS_TRAINING_ROUTES.include?(training_route)
  end

  def course_age_range
    return unless require_age_range?

    (other_age_range? ? additional_age_range : main_age_range).split(" to ")
  end

  def itt_start_date
    new_date({ year: start_year, month: start_month, day: start_day })
  end

  def itt_end_date
    return if end_date_not_required? && end_date_not_provided?

    new_date({ year: end_year, month: end_month, day: end_day })
  end

  def save!
    if valid?
      update_trainee_attributes
      clear_funding_information if clear_funding_information?
      Trainees::Update.call(trainee:)
      clear_all_course_related_stashes
    else
      false
    end
  end

  def has_additional_subjects?
    course_subject_two.present? || course_subject_three.present?
  end

  def require_subject?
    EARLY_YEARS_TRAINING_ROUTES.exclude?(training_route)
  end

  def require_age_range?
    return false if trainee.api_record?

    EARLY_YEARS_TRAINING_ROUTES.exclude?(training_route)
  end

  def course_education_phase
    @course_education_phase ||= ::CourseEducationPhaseForm.new(trainee).course_education_phase
  end

  def course_allocation_subject
    @course_allocation_subject ||= SubjectSpecialism.find_by(name: course_subject_one)&.allocation_subject
  end

  def is_primary_phase?
    course_education_phase == COURSE_EDUCATION_PHASE_ENUMS[:primary]
  end

  def attrs_from_course_age_range(course_age_range)
    age_range = DfE::ReferenceData::AgeRanges::AGE_RANGES.one(course_age_range)

    attrs = {}
    if age_range.present? && !trainee.early_years_route?
      attrs[:"#{age_range[:option]}_age_range"] = course_age_range.join(" to ")
      attrs[:main_age_range] = :other if age_range[:option] == :additional
    end

    attrs
  end

  def nullify_and_stash!
    opts = FIELDS.inject({}) { |sum, f|
      sum[f] = nil
      sum
    }
    assign_attributes_and_stash(opts)
  end

private

  attr_reader :training_routes_form

  def requires_secondary_subjects?
    !is_primary_phase? && require_subject?
  end

  def requires_primary_subjects?
    is_primary_phase? && require_subject?
  end

  def compute_fields
    compute_attributes_from_trainee.merge(new_attributes)
  end

  def other_age_range?
    main_age_range&.to_sym == :other
  end

  def primary_with_other?
    primary_course_subjects&.to_sym == :other
  end

  def set_primary_phase_subjects
    return if course_subject_one.blank?

    PUBLISH_PRIMARY_SUBJECT_SPECIALISM_MAPPING.key([course_subject_one, course_subject_two, course_subject_three].compact_blank) || :other
  end

  def set_course_subject_from_primary_phase
    if PUBLISH_PRIMARY_SUBJECTS.include?(primary_course_subjects)
      @course_subject_one, @course_subject_two, @course_subject_three = PUBLISH_PRIMARY_SUBJECT_SPECIALISM_MAPPING[primary_course_subjects]
    end

    @course_subject_one = ::CourseSubjects::PRIMARY_TEACHING if primary_with_other?
  end

  def set_early_years_attributes
    @course_subject_one = ::CourseSubjects::EARLY_YEARS_TEACHING

    @course_allocation_subject = SubjectSpecialism.find_by(name: @course_subject_one)&.allocation_subject
  end

  def update_trainee_attributes
    attributes = {
      course_uuid:,
      itt_start_date:,
      itt_end_date:,
      training_route:,
      course_education_phase:,
    }

    set_course_subject_from_primary_phase if is_primary_phase?

    attributes.merge!(course_uuid: nil) if course_allocation_subject_changed?

    if early_years_route?
      attributes.merge!({
        course_subject_one: course_subject_one,
        course_subject_two: nil,
        course_subject_three: nil,
        course_age_range: nil,
        course_allocation_subject: course_allocation_subject,
      })
    else
      attributes.merge!({
        course_subject_one: course_subject_one,
        course_subject_two: course_subject_two.presence,
        course_subject_three: course_subject_three.presence,
        course_age_range: course_age_range,
        course_allocation_subject: course_allocation_subject,
      })
    end

    if requires_study_mode?
      attributes.merge!({
        study_mode:,
      })
    end

    trainee.assign_attributes(attributes)
  end

  def compute_attributes_from_trainee
    attributes = {
      course_uuid: trainee.course_uuid,
      start_day: trainee.itt_start_date&.day,
      start_month: trainee.itt_start_date&.month,
      start_year: trainee.itt_start_date&.year,
      end_day: trainee.itt_end_date&.day,
      end_month: trainee.itt_end_date&.month,
      end_year: trainee.itt_end_date&.year,
    }

    unless trainee.early_years_route?
      attributes.merge!({
        course_subject_one: trainee.course_subject_one,
        course_subject_two: trainee.course_subject_two,
        course_subject_three: trainee.course_subject_three,
      })
    end

    if trainee.requires_study_mode?
      attributes.merge!({
        study_mode: trainee.study_mode,
      })
    end

    age_range = DfE::ReferenceData::AgeRanges::AGE_RANGES.one(trainee.course_age_range)

    if age_range.present? && !trainee.early_years_route?
      attributes[:"#{age_range[:option]}_age_range"] = trainee.course_age_range.join(" to ")
      attributes[:main_age_range] = :other if age_range[:option] == :additional
    end

    attributes
  end

  def new_date(date_hash)
    date_args = date_hash.values.map(&:to_i)
    valid_date?(date_args) ? Date.new(*date_args) : InvalidDate.new(date_hash)
  end

  def primary_courses_valid
    if primary_course_subjects.blank?
      errors.add(:primary_course_subjects, :blank)
    end

    if primary_with_other?
      errors.add(:course_subject_two, :blank) if course_subject_two.blank?
    elsif PUBLISH_PRIMARY_SUBJECTS.exclude?(primary_course_subjects)
      errors.add(:primary_course_subjects, :inclusion)
    end
  end

  def age_range_valid
    if main_age_range.blank?
      errors.add(:main_age_range, :blank)
    elsif other_age_range? && additional_age_range.blank?
      errors.add(:additional_age_range, :blank)
    end
  end

  def itt_start_date_valid
    if [start_day, start_month, start_year].all?(&:blank?)
      errors.add(:itt_start_date, :blank)
    elsif start_year.to_i > next_year
      errors.add(:itt_start_date, :future)
    elsif !itt_start_date.is_a?(Date)
      errors.add(:itt_start_date, :invalid)
    elsif before_academic_cycle_starts?(itt_start_date)
      errors.add(:itt_start_date, :too_old)
    end
  end

  def itt_end_date_valid
    return true if end_date_not_required? && end_date_not_provided?

    if [end_day, end_month, end_year].all?(&:blank?)
      errors.add(:itt_end_date, :blank)
    elsif end_year.to_i > max_years
      errors.add(:itt_end_date, :future)
    elsif !itt_end_date.is_a?(Date)
      errors.add(:itt_end_date, :invalid)
    elsif itt_end_date < 10.years.ago
      errors.add(:itt_end_date, :too_old)
    end

    additional_validation = errors.attribute_names.none? do |attribute_name|
      %i[itt_start_date itt_end_date].include?(attribute_name)
    end

    if additional_validation && itt_start_date >= itt_end_date
      errors.add(:itt_end_date, :before_or_same_as_start_date)
    end
  end

  def course_subject_two_valid
    return if course_subject_two.blank?

    errors.add(:course_subject_two, :duplicate) if course_subject_one == course_subject_two
  end

  def course_subject_three_valid
    return if course_subject_three.blank?

    errors.add(:course_subject_three, :duplicate) if [course_subject_one, course_subject_two].include?(course_subject_three)
  end

  def next_year
    Time.zone.now.year.next
  end

  def max_years
    next_year + MAX_END_YEARS
  end

  def before_academic_cycle_starts?(date)
    return false unless date && academic_cycle

    date < academic_cycle.start_date
  end

  def course
    @course ||= trainee.available_courses&.find_by(uuid: course_uuid)
  end

  def academic_cycle
    @academic_cycle ||= (AcademicCycle.for_year(course.recruitment_cycle_year) if course)
  end

  def sanitise_subjects
    return if course_subject_two.present? || course_subject_two_raw.present?

    self.course_subject_two = course_subject_three
    self.course_subject_two_raw = course_subject_three_raw

    self.course_subject_three = nil
    self.course_subject_three_raw = nil
  end

  def sanitise_course_dates
    return if COURSE_DATES.any?(&:nil?)

    COURSE_DATES.each do |date_attribute|
      sanitised_date = public_send(date_attribute).to_s.gsub(/\s+/, "")
      public_send("#{date_attribute}=", sanitised_date)
    end
  end

  def course_allocation_subject_changed?
    trainee.course_allocation_subject != course_allocation_subject
  end
end
