# frozen_string_literal: true

class MultiDateForm < TraineeForm
  include DatesHelper

  attr_accessor :day, :month, :year, :date_string

  PARAM_CONVERSION = {
    "date(3i)" => "day",
    "date(2i)" => "month",
    "date(1i)" => "year",
  }.freeze

  def date
    return unless date_string

    {
      today: Time.zone.today,
      yesterday: Time.zone.yesterday,
      other: other_date,
    }[date_string.to_sym]
  end

  def add_date_fields(new_d)
    fields.merge!({
      date_string: rehydrate_date_string(new_d),
      day: new_d&.day,
      month: new_d&.month,
      year: new_d&.year,
    })
  end

private

  def compute_fields
    {
      date_string: rehydrate_date_string,
      day: trainee_attribute&.day,
      month: trainee_attribute&.month,
      year: trainee_attribute&.year,
    }.merge(additional_fields).merge(new_attributes.slice(:day, :month, :year, :date_string, *additional_fields.keys))
  end

  def date_field
    raise("Subclass of MultiDateForm must implement #date_field")
  end

  def trainee_attribute
    trainee.public_send(date_field)
  end

  def additional_fields
    {}
  end

  def rehydrate_date_string(date = trainee_attribute)
    return unless date

    case date
    when Time.zone.today
      "today"
    when Time.zone.yesterday
      "yesterday"
    else
      "other"
    end
  end

  def assign_attributes_to_trainee
    trainee[date_field] = date
  end

  def other_date
    date_hash = { year:, month:, day: }
    date_args = date_hash.values.map(&:to_i)

    valid_date?(date_args) ? Date.new(*date_args) : InvalidDate.new(date_hash)
  end

  def date_valid
    if date_string.nil?
      errors.add(:date_string, :blank)
    elsif date_string == "other" && [day, month, year].all?(&:blank?)
      errors.add(:date, :blank)
    elsif !date.is_a?(Date)
      errors.add(:date, :invalid)
    elsif date_before_itt_start_date?(date, trainee.itt_start_date)
      errors.add(:date, I18n.t("activemodel.errors.models.deferral_form.attributes.date.not_before_itt_start_date").html_safe)
    end
  end
end
