# frozen_string_literal: true

class CourseDetailsForm < TraineeForm
  FIELDS = %i[
    subject
    subject_raw
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

  validates :subject, autocomplete: true, presence: true
  validates :additional_age_range, autocomplete: true, if: -> { other_age_range? }
  validate :age_range_valid
  validate :course_start_date_valid
  validate :course_end_date_valid

  MAX_END_YEARS = 4

  def course_age_range
    (other_age_range? ? additional_age_range : main_age_range).split(" to ")
  end

  def course_start_date
    new_date({ year: start_year, month: start_month, day: start_day })
  end

  def course_end_date
    new_date({ year: end_year, month: end_month, day: end_day })
  end

  def save!
    if valid?
      update_trainee_attributes
      trainee.save!
      clear_stash
    else
      false
    end
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
      subject: subject,
      course_age_range: course_age_range,
      course_start_date: course_start_date,
      course_end_date: course_end_date,
    })
  end

  def compute_attributes_from_trainee
    attributes = {
      subject: trainee.subject,
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

  def next_year
    Time.zone.now.year.next
  end

  def max_years
    next_year + MAX_END_YEARS
  end

  def sanitise_course_dates
    return if COURSE_DATES.any?(&:nil?)

    COURSE_DATES.each do |date_attribute|
      sanitised_date = public_send(date_attribute).to_s.gsub(/\s+/, "")
      public_send("#{date_attribute}=", sanitised_date)
    end
  end
end
