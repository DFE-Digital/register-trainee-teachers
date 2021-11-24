# frozen_string_literal: true

class TraineeStartDateForm < TraineeForm
  include DatesHelper
  include CommencementDateHelpers

  attr_accessor :day, :month, :year, :context

  WITHDRAW = "withdraw"
  DEFER = "defer"
  DELETE = "delete"

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

  def deferring?
    context == DEFER
  end

  def itt_start_date_is_after_deferral_date?
    deferral_date.is_a?(Date) && commencement_date.after?(deferral_date)
  end

private

  def deferral_date
    @deferral_date ||= ::DeferralForm.new(trainee).date
  end

  def compute_fields
    {
      day: trainee.commencement_date&.day,
      month: trainee.commencement_date&.month,
      year: trainee.commencement_date&.year,
    }.merge(new_attributes.slice(:day, :month, :year, :context))
  end

  def update_trainee_commencement_date
    trainee.assign_attributes(commencement_date: commencement_date)
  end

  def fields_from_store
    store.get(trainee.id, :trainee_start_date).presence || {}
  end
end
