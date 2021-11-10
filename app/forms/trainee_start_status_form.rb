# frozen_string_literal: true

class TraineeStartStatusForm < TraineeForm
  include DatesHelper

  FIELDS = %i[
    commencement_status
    commencement_date
    day
    month
    year
  ].freeze

  attr_accessor(*FIELDS)

  validates :commencement_status, presence: true
  validate :commencement_date_valid, if: :itt_started_later?

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
    @commencement_date ||= begin
      set_on_time_itt_start_date if itt_started_on_time?
      unset_itt_start_date if itt_not_yet_started?

      date_hash = { year: year, month: month, day: day }
      date_args = date_hash.values.map(&:to_i)

      valid_date?(date_args) ? Date.new(*date_args) : OpenStruct.new(date_hash)
    end
  end

  def itt_not_yet_started?
    commencement_status&.to_sym == :itt_not_yet_started
  end

  def itt_started_on_time?
    commencement_status&.to_sym == :itt_started_on_time
  end

  def itt_started_later?
    commencement_status&.to_sym == :itt_started_later
  end

private

  def set_on_time_itt_start_date
    self.day = trainee.course_start_date.day
    self.month = trainee.course_start_date.month
    self.year = trainee.course_start_date.year
  end

  def unset_itt_start_date
    self.day = nil
    self.month = nil
    self.year = nil
  end

  def compute_fields
    {
      commencement_status: trainee.commencement_status,
      day: trainee.commencement_date&.day,
      month: trainee.commencement_date&.month,
      year: trainee.commencement_date&.year,
    }.merge(new_attributes.slice(:day, :month, :year, :commencement_status))
  end

  def update_trainee_commencement_date
    return unless errors.empty?

    trainee.assign_attributes(commencement_date: formatted_commencement_date, commencement_status: commencement_status)
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

  def fields_from_store
    store.get(trainee.id, :trainee_start_status).presence || {}
  end

  def formatted_commencement_date
    commencement_date.is_a?(Date) ? commencement_date : nil
  end
end
