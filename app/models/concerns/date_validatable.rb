# frozen_string_literal: true

module DateValidatable
  extend ActiveSupport::Concern

  def valid_date_string?(date)
    Date.iso8601(date.to_s)
    true
  rescue StandardError
    false
  end
end
