# frozen_string_literal: true

def current_recruitment_cycle_year
  current_date = Time.zone.now
  current_year = current_date.year
  return current_year - 1 if current_date < Date.new(current_year, 1, 10)

  current_year
end
