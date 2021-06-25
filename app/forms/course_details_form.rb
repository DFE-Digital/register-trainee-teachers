# frozen_string_literal: true

class CourseDetailsForm < TraineeForm
  FIELDS = %i[
    course_subject_one
    course_subject_one_raw
    course_subject_two
    course_subject_two_raw
    course_subject_three
    course_subject_three_raw
    start_day
    start_month
    start_year
    end_day
    end_month
    end_year
    main_age_range
    additional_age_range
    additional_age_range_raw
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

  validates :course_subject_one, autocomplete: true, presence: true, if: :require_subject?
  validates :course_subject_two, autocomplete: true, if: :require_subject?
  validates :course_subject_three, autocomplete: true, if: :require_subject?
  validates :additional_age_range, autocomplete: true, if: -> { other_age_range? && require_age_range? }

  validate :course_start_date_valid
  validate :course_end_date_valid

  validate :age_range_valid, if: :require_age_range?
  validate :course_subject_two_valid, if: :require_subject?
  validate :course_subject_three_valid, if: :require_subject?

  delegate :apply_application?, to: :trainee

  MAX_END_YEARS = 4

  def course_age_range
    return unless require_age_range?

    (other_age_range? ? additional_age_range : main_age_range).split(" to ")
  end

  def course_start_date
    new_date({ year: start_year, month: start_month, day: start_day })
  end

  def course_end_date
    new_date({ year: end_year, month: end_month, day: end_day })
  end

  def course_code
    return nil unless trainee.draft?

    trainee.course_code
  end

  def save!
    if valid?
      update_trainee_attributes
      clear_bursary_information if course_subjects_changed?
      trainee.save!
      clear_stash
    else
      false
    end
  end

  def has_additional_subjects?
    course_subject_two.present? || course_subject_three.present?
  end

  def require_subject?
    !trainee.early_years_route?
  end

  def require_age_range?
    !trainee.early_years_route?
  end

private

  def compute_fields
    compute_attributes_from_trainee.merge(new_attributes)
  end

  def other_age_range?
    main_age_range&.to_sym == :other
  end

  def update_trainee_attributes
    trainee.assign_attributes({
      course_code: course_code,
      course_subject_one: course_subject_one,
      course_subject_two: course_subject_two,
      course_subject_three: course_subject_three,
      course_age_range: course_age_range,
      course_start_date: course_start_date,
      course_end_date: course_end_date,
    })
  end

  def clear_bursary_information
    trainee.progress.funding = false

    trainee.assign_attributes({
      applying_for_bursary: nil,
    })
  end

  def course_subjects_changed?
    trainee.course_subject_one_changed? || trainee.course_subject_two_changed? || trainee.course_subject_three_changed?
  end

  def compute_attributes_from_trainee
    attributes = {
      course_subject_one: trainee.course_subject_one,
      course_subject_two: trainee.course_subject_two,
      course_subject_three: trainee.course_subject_three,
      start_day: trainee.course_start_date&.day,
      start_month: trainee.course_start_date&.month,
      start_year: trainee.course_start_date&.year,
      end_day: trainee.course_end_date&.day,
      end_month: trainee.course_end_date&.month,
      end_year: trainee.course_end_date&.year,
    }

    age_range = Dttp::CodeSets::AgeRanges::MAPPING[trainee.course_age_range]

    if age_range.present?
      attributes["#{age_range[:option]}_age_range".to_sym] = trainee.course_age_range.join(" to ")
      attributes[:main_age_range] = :other if age_range[:option] == :additional
    end

    attributes
  end

  def new_date(date_hash)
    date_args = date_hash.values.map(&:to_i)
    Date.valid_date?(*date_args) ? Date.new(*date_args) : OpenStruct.new(date_hash)
  end

  def age_range_valid
    if main_age_range.blank?
      errors.add(:main_age_range, :blank)
    elsif other_age_range? && additional_age_range.blank?
      errors.add(:additional_age_range, :blank)
    end
  end

  def course_start_date_valid
    if [start_day, start_month, start_year].all?(&:blank?)
      errors.add(:course_start_date, :blank)
    elsif start_year.to_i > next_year
      errors.add(:course_start_date, :future)
    elsif !course_start_date.is_a?(Date)
      errors.add(:course_start_date, :invalid)
    elsif course_start_date < 10.years.ago
      errors.add(:course_start_date, :too_old)
    end
  end

  def course_end_date_valid
    if [end_day, end_month, end_year].all?(&:blank?)
      errors.add(:course_end_date, :blank)
    elsif end_year.to_i > max_years
      errors.add(:course_end_date, :future)
    elsif !course_end_date.is_a?(Date)
      errors.add(:course_end_date, :invalid)
    elsif course_end_date < 10.years.ago
      errors.add(:course_end_date, :too_old)
    end

    additional_validation = errors.attribute_names.none? do |attribute_name|
      %i[course_start_date course_end_date].include?(attribute_name)
    end

    if additional_validation && course_start_date >= course_end_date
      errors.add(:course_end_date, :before_or_same_as_start_date)
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
end
