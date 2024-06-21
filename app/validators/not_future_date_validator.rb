# frozen_string_literal: true

class NotFutureDateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    record.errors.add(attribute, :future) if future_date?(record.public_send(attribute))
  end

private

  def future_date?(date)
    Date.parse(date).future?
  end
end
