# frozen_string_literal: true

class SignOffPeriodService
  CENSUS_MONTH = 10 # October
  PERFORMANCE_MONTH = 1 # January

  def self.call
    today_month = Time.zone.today.month

    return :census_period if today_month == CENSUS_MONTH
    return :performance_period if today_month == PERFORMANCE_MONTH

    :outside_period
  end
end
