# frozen_string_literal: true

def current_academic_year
  Time.zone.now.month >= ACADEMIC_CYCLE_START_MONTH ? Time.zone.now.year : Time.zone.now.year - 1
end

def skip_test_due_to_first_day_of_current_academic_year?
  "bunk off school" if the_very_first_day_of_current_academic_year?
end

def the_very_first_day_of_current_academic_year?
  (Time.zone.now.month == ACADEMIC_CYCLE_START_MONTH && Time.zone.now.day == 1) || ENV.fetch("USE_NEXT_ACADEMIC_YEAR", false) == "true"
end

def compute_valid_past_itt_start_date
  if Time.zone.now.month == ACADEMIC_CYCLE_START_MONTH
    if Time.zone.now.day == 1
      Time.zone.now
    else
      Faker::Date.between(from: Time.zone.now.beginning_of_month, to: Time.zone.now.yesterday)
    end
  else
    Faker::Date.in_date_period(month: ACADEMIC_CYCLE_START_MONTH, year: current_academic_year)
  end
end

def compute_valid_future_itt_start_date
  if Settings.current_recruitment_cycle_year > current_academic_year
    Faker::Date.in_date_period(month: ACADEMIC_CYCLE_START_MONTH, year: Settings.current_recruitment_cycle_year)
  elsif Settings.apply_applications.create.recruitment_cycle_year > current_academic_year
    Faker::Date.in_date_period(month: ACADEMIC_CYCLE_START_MONTH, year: Settings.apply_applications.create.recruitment_cycle_year)
  end
end

def compute_valid_itt_start_date
  compute_valid_future_itt_start_date || compute_valid_past_itt_start_date
end
