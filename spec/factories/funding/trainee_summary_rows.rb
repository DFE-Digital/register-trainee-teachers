# frozen_string_literal: true

FactoryBot.define do
  factory :trainee_summary_row, class: "Funding::TraineeSummaryRow" do
    association :trainee_summary, factory: :trainee_summary

    subject { "Biology" }
    route { "Provider-led" }
    lead_school_name { "The School of Life" }
    lead_school_urn { Faker::Number.number(digits: 7) }
    cohort_level { "PG" }

    trait :with_grant_amount do
      route { "School direct (salaried)" }
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
      route { "Early years (salaried)" }
      amounts do
        [build(:trainee_summary_row_amount, :with_tiered_bursary)]
      end
    end
  end
end
