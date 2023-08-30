# frozen_string_literal: true

class DetermineSignOffPeriod
  CENSUS_MONTHS = [8, 9, 10].freeze # September, October
  PERFORMANCE_MONTH = 1 # January

  def self.call
    current_month = Time.zone.today.month

    return :census_period if CENSUS_MONTHS.include?(current_month)
    return :performance_period if current_month == PERFORMANCE_MONTH

    :outside_period
  end
end
