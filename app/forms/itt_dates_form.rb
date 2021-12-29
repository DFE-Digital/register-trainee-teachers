# frozen_string_literal: true

class IttDatesForm < TraineeForm
  include DatesHelper

  MAX_END_YEARS = 4

  FIELDS = %i[
    start_day
    start_month
    start_year
    end_day
    end_month
    end_year
    course_uuid
    is_for_all_trainees
  ].freeze

  attr_accessor(*FIELDS, :course)

  validate :start_date_valid, :end_date_valid

  delegate :study_mode, to: :course_details_form

  def initialize(...)
    super(...)
    @course_details_form = CourseDetailsForm.new(trainee)
    @course = trainee.available_courses&.find_by(uuid: course_uuid)
  end

  def save!
    if valid?
      update_trainee_itt_dates
      trainee.save!
      copy_dates_to_course if for_all_trainees?
      clear_stash
    else
      false
    end
  end

  def stash
    course_details_form.assign_attributes_and_stash({
      start_day: start_day,
      start_month: start_month,
      start_year: start_year,
      end_day: end_day,
      end_month: end_month,
      end_year: end_year,
    })

    super
  end

  def start_date
    compute_date({ year: start_year, month: start_month, day: start_day })
  end

  def end_date
    compute_date({ year: end_year, month: end_month, day: end_day })
  end

private

  attr_accessor :course_details_form

  def compute_fields
    {
      start_day: trainee.itt_start_date&.day,
      start_month: trainee.itt_start_date&.month,
      start_year: trainee.itt_start_date&.year,
      end_day: trainee.itt_end_date&.day,
      end_month: trainee.itt_end_date&.month,
      end_year: trainee.itt_end_date&.year,
    }.merge(new_attributes)
  end

  def update_trainee_itt_dates
    trainee.assign_attributes({ itt_start_date: start_date, itt_end_date: end_date })
  end

  def for_all_trainees?
    ActiveModel::Type::Boolean.new.cast(is_for_all_trainees)
  end

  def compute_date(date_hash)
    date_args = date_hash.values.map(&:to_i)

    return unless valid_date?(date_args)

    Date.new(*date_args)
  end

  def start_date_valid
    if [start_day, start_month, start_year].all?(&:blank?)
      errors.add(:start_date, :blank)
    elsif start_year.to_i > next_year
      errors.add(:start_date, :future)
    elsif !start_date.is_a?(Date)
      errors.add(:start_date, :invalid)
    elsif start_date < earliest_valid_start_date
      errors.add(:start_date, :too_old)
    elsif outside_academic_cycle?(start_date)
      errors.add(:start_date, :not_within_academic_cycle)
    end
  end

  def end_date_valid
    if [end_day, end_month, end_year].all?(&:blank?)
      errors.add(:end_date, :blank)
    elsif end_year.to_i > max_years
      errors.add(:end_date, :future)
    elsif !end_date.is_a?(Date)
      errors.add(:end_date, :invalid)
    elsif end_date < 10.years.ago
      errors.add(:end_date, :too_old)
    end

    additional_validation = errors.attribute_names.none? do |attribute_name|
      %i[start_date end_date].include?(attribute_name)
    end

    if additional_validation && start_date >= end_date
      errors.add(:end_date, :before_or_same_as_start_date)
    end
  end

  def outside_academic_cycle?(date)
    return false unless date && academic_cycle

    !date.between?(academic_cycle.start_date, academic_cycle.end_date)
  end

  def academic_cycle
    @academic_cycle ||= AcademicCycle.for_year(course.recruitment_cycle_year)
  end

  def next_year
    Time.zone.now.year.next
  end

  def max_years
    next_year + MAX_END_YEARS
  end

  def earliest_valid_start_date
    Date.parse("1/8/2020")
  end

  def copy_dates_to_course
    course.update("#{study_mode}_start_date" => start_date, "#{study_mode}_end_date" => end_date)
  end
end
