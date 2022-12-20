# frozen_string_literal: true

FactoryBot.define do
  factory :academic_cycle do
    transient do
      one_before_previous_cycle { false }
      previous_cycle { false }
      next_cycle { false }
      one_after_next_cycle { false }

      cycle_year do
        cycles = [
          -> { current_academic_year - 2 if one_before_previous_cycle },
          -> { current_academic_year - 1 if previous_cycle },
          -> { current_academic_year + 1 if next_cycle },
          -> { current_academic_year + 2 if one_after_next_cycle },
        ].map(&:call).compact

        cycles.any? ? cycles.first : current_academic_year
      end
    end

    start_date do
      Date.new(cycle_year, 8, 1)
    end

    end_date do
      Date.new(cycle_year + 1, 7, 31)
    end

    trait :current do
      cycle_year { current_academic_year }
    end
  end
end
