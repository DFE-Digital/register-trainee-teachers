# frozen_string_literal: true

class TraineeStartDateForm < TraineeForm
  include TrainingDatesHelper

  attr_accessor :day, :month, :year

  validate :commencement_date_valid

  def save!
    if valid?
      update_trainee_commencement_date
      trainee.save!
      clear_stash
    else
      false
    end
  end

  def commencement_date
    date_hash = { year: year, month: month, day: day }
    date_args = date_hash.values.map(&:to_i)

    valid_date?(date_args) ? Date.new(*date_args) : OpenStruct.new(date_hash)
  end

private

  def compute_fields
    {
      day: trainee.commencement_date&.day,
      month: trainee.commencement_date&.month,
      year: trainee.commencement_date&.year,
    }.merge(new_attributes.slice(:day, :month, :year))
  end

  def update_trainee_commencement_date
    trainee.assign_attributes(commencement_date: commencement_date) if errors.empty?
  end

  def commencement_date_valid
    if [day, month, year].all?(&:blank?)
      errors.add(:commencement_date, :blank)
    elsif !commencement_date.is_a?(Date)
      errors.add(:commencement_date, :invalid)
    elsif date_before_course_start_date?(commencement_date, trainee.course_start_date)
      errors.add(:commencement_date, :not_before_course_start_date)
    end
  end

  def valid_date?(date_args)
    Date.valid_date?(*date_args) && date_args.all?(&:positive?)
  end

  def fields_from_store
    store.get(trainee.id, :trainee_start_date).presence || {}
  end
end
