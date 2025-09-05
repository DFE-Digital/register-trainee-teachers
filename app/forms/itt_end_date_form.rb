# frozen_string_literal: true

class IttEndDateForm < TraineeForm
  include DatesHelper

  MAX_END_YEARS = 4

  attr_accessor :day, :month, :year

  validate :itt_end_date_valid

  def save!
    if valid?
      update_itt_end_date
      Trainees::Update.call(trainee:)
      clear_stash
    else
      false
    end
  end

  def itt_end_date
    date_hash = { year:, month:, day: }
    date_args = date_hash.values.map(&:to_i)

    valid_date?(date_args) ? Date.new(*date_args) : InvalidDate.new(date_hash)
  end

private

  def compute_fields
    {
      day: trainee.itt_end_date&.day,
      month: trainee.itt_end_date&.month,
      year: trainee.itt_end_date&.year,
    }.merge(new_attributes.slice(:day, :month, :year))
  end

  def update_itt_end_date
    trainee.assign_attributes(itt_end_date:)
  end

  def fields_from_store
    store.get(trainee.id, :itt_end_date).presence || {}
  end

  def itt_end_date_valid
    if [day, month, year].all?(&:blank?)
      errors.add(:itt_end_date, :blank)
    elsif year.to_i > max_years
      errors.add(:itt_end_date, :future)
    elsif !itt_end_date.is_a?(Date)
      errors.add(:itt_end_date, :invalid)
    elsif itt_end_date < return_date
      errors.add(:itt_end_date, :return_date)
    end
  end

  def next_year
    Time.zone.now.year.next
  end

  def max_years
    next_year + MAX_END_YEARS
  end

  def return_date
    reinstatement_form.date
  end

  def reinstatement_form
    @reinstatement_form ||= ReinstatementForm.new(trainee)
  end
end
