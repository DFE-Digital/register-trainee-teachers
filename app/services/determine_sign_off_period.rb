# frozen_string_literal: true

class DetermineSignOffPeriod
  VALID_PERIODS = %i[census_period performance_period outside_period].freeze

  def self.call
    return Settings.sign_off_period.to_sym if valid_sign_off_period?

    current_date = Time.zone.today

    return :census_period if census_range.cover?(current_date)

    return :performance_period if in_performance_range?(current_date)

    :outside_period
  end

  def self.valid_sign_off_period?
    return false if Settings.sign_off_period.blank?
    return true if VALID_PERIODS.include?(Settings.sign_off_period.to_sym)

    Sentry.capture_exception(StandardError.new("Invalid sign_off_period value: #{Settings.sign_off_period}"))
    false
  end

  def self.census_range
    start_date = Date.new(Time.zone.today.year, 9, 1) # 1st September
    end_date = Date.new(Time.zone.today.year, 11, 7) # 7th November

    start_date..end_date
  end

  def self.in_performance_range?(date)
    jan_to_feb_range = Date.new(Time.zone.today.year, 1, 1)..Date.new(Time.zone.today.year, 2, 7)
    december_range = Date.new(Time.zone.today.year, 12, 1)..Date.new(Time.zone.today.year, 12, 31)

    jan_to_feb_range.cover?(date) || december_range.cover?(date)
  end
end
