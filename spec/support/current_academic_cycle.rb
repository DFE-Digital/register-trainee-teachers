# frozen_string_literal: true

def current_academic_year
  Time.zone.now.month >= ACADEMIC_CYCLE_START_MONTH ? Time.zone.now.year : Time.zone.now.year - 1
end

def compute_valid_itt_start_date
  # The itt_start_date always needs to be in the past.
  if Time.zone.now.month == ACADEMIC_CYCLE_START_MONTH
    Faker::Date.between(from: Time.zone.now.beginning_of_month, to: Time.zone.now.yesterday)
  else
    Faker::Date.in_date_period(month: ACADEMIC_CYCLE_START_MONTH, year: current_academic_year)
  end
end
