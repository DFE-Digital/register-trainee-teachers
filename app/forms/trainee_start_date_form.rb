# frozen_string_literal: true

class TraineeStartDateForm < TraineeForm
  include DatesHelper
  include CommencementDateHelpers

  attr_accessor :day, :month, :year, :context

  WITHDRAW = "withdraw"
  DEFER = "defer"
  DELETE = "delete"

  validate :trainee_start_date_valid

  def save!
    if valid?
      update_trainee_start_date
      Trainees::Update.call(trainee: trainee)
      clear_stash
    else
      false
    end
  end

  def trainee_start_date
    date_hash = { year: year, month: month, day: day }
    date_args = date_hash.values.map(&:to_i)

    valid_date?(date_args) ? Date.new(*date_args) : InvalidDate.new(date_hash)
  end

  def deferring?
    context == DEFER
  end

  def itt_start_date_is_after_deferral_date?
    deferral_date.is_a?(Date) && trainee_start_date.after?(deferral_date)
  end

private

  def deferral_date
    @deferral_date ||= ::DeferralForm.new(trainee).date
  end

  def compute_fields
    {
      day: trainee.trainee_start_date&.day,
      month: trainee.trainee_start_date&.month,
      year: trainee.trainee_start_date&.year,
    }.merge(new_attributes.slice(:day, :month, :year, :context))
  end

  def update_trainee_start_date
    trainee.assign_attributes(trainee_start_date: trainee_start_date, commencement_status: commencement_status)
  end

  def commencement_status
    if trainee_start_date.after?(trainee.itt_start_date)
      COMMENCEMENT_STATUS_ENUMS[:itt_started_later]
    else
      COMMENCEMENT_STATUS_ENUMS[:itt_started_on_time]
    end
  end

  def fields_from_store
    store.get(trainee.id, :trainee_start_date).presence || {}
  end
end
