# frozen_string_literal: true

FactoryBot.define do
  factory :academic_cycle do
    transient do
      next_cycle { false }
      previous_cycle { false }

      cycle_year do
        cycles = [
          -> { current_recruitment_cycle_year + 1 if next_cycle },
          -> { current_recruitment_cycle_year - 1 if previous_cycle },
        ].map(&:call).compact

        cycles.any? ? cycles.first : current_recruitment_cycle_year
      end
    end

    start_date do
      Date.new(cycle_year, 8, 1)
    end

    end_date do
      Date.new(cycle_year + 1, 7, 31)
    end

    trait :current do
      cycle_year { Time.zone.now.month >= 8 ? Time.zone.now.year : Time.zone.now.year - 1 }
    end
  end
end
