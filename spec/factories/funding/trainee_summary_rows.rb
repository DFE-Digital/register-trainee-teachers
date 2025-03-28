# frozen_string_literal: true

FactoryBot.define do
  factory :trainee_summary_row, class: "Funding::TraineeSummaryRow" do
    trainee_summary

    subject { "Biology" }
    route { "Provider-led" }
    training_route { "provider_led_postgrad" }
    lead_school_name { "The School of Life" }
    lead_school_urn { Faker::Number.number(digits: 7) }
    cohort_level { "PG" }

    trait :with_grant_amount do
      route { "School Direct salaried" }
      training_route { "school_direct_salaried" }

      amounts do
        [build(:trainee_summary_row_amount, :with_grant)]
      end
    end

    trait :with_bursary_amount do
      amounts do
        [build(:trainee_summary_row_amount, :with_bursary)]
      end
    end

    trait :with_scholarship_amount do
      amounts do
        [build(:trainee_summary_row_amount, :with_scholarship)]
      end
    end

    trait :with_tiered_bursary_amount do
      route { "EYITT Graduate employment-based" }
      training_route { "early_years_salaried" }

      amounts do
        [build(:trainee_summary_row_amount, :with_tiered_bursary)]
      end
    end

    trait :with_multiple_amounts do
      route { "EYITT Graduate employment-based" }
      training_route { "early_years_salaried" }

      amounts do
        [
          build(:trainee_summary_row_amount, :with_bursary),
          build(:trainee_summary_row_amount, :with_scholarship),
        ]
      end
    end
  end
end
