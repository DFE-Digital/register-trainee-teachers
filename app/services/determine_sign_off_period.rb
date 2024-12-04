# frozen_string_literal: true

class DetermineSignOffPeriod
  include ServicePattern

  VALID_PERIODS = %i[census_period performance_period outside_period].freeze

  def initialize(previous_academic_cycle: AcademicCycle.previous)
    @previous_academic_cycle = previous_academic_cycle
  end

  def call
    return Settings.sign_off_period.to_sym if valid_sign_off_period?

    current_date = Time.zone.today

    return :census_period if census_range.cover?(current_date)

    return :performance_period if in_performance_profile_range?(current_date)

    :outside_period
  end

private

  attr_reader :previous_academic_cycle

  def valid_sign_off_period?
    return false if Settings.sign_off_period.blank?
    return true if VALID_PERIODS.include?(Settings.sign_off_period.to_sym)

    Sentry.capture_exception(StandardError.new("Invalid sign_off_period value: #{Settings.sign_off_period}"))
    false
  end

  def census_range
    start_date = Date.new(Time.zone.today.year, 9, 1) # 1st September
    end_date = Date.new(Time.zone.today.year, 11, 7) # 7th November

    start_date..end_date
  end

  delegate :in_performance_profile_range?, to: :previous_academic_cycle
end
