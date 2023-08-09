# frozen_string_literal: true

class SignOffPeriodService
  # Census sign off period: 1st October - 31st October
  CENSUS_PERIOD = (Date.new(Time.zone.today.year, 10, 1)..Date.new(Time.zone.today.year, 10, 31))

  # Performance profiles sign off period: 1st January - 31st January
  PERFORMANCE_PERIOD = (Date.new(Time.zone.today.year, 1, 1)..Date.new(Time.zone.today.year, 1, 31))

  def self.call
    today = Time.zone.today

    return :census_period if CENSUS_PERIOD.cover?(today)
    return :performance_period if PERFORMANCE_PERIOD.cover?(today)

    :outside_period
  end
end
