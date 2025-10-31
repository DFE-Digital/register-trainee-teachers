# frozen_string_literal: true

class DateFutureLimitValidator < ActiveModel::EachValidator
  include ActionView::Helpers::DateHelper

  def validate_each(record, attribute, value)
    return if !value.is_a?(Date)

    return true if value < options[:with].from_now

    record.errors.add(attribute, :future_limit, limit: distance_of_time_in_words(options[:with]))
  end
end
