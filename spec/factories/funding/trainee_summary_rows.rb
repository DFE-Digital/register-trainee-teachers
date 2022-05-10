# frozen_string_literal: true

FactoryBot.define do
  factory :trainee_summary_row, class: "Funding::TraineeSummaryRow" do
    association :trainee_summary, factory: :trainee_summary

    subject { "Biology" }
    route { "Provider-led" }
    lead_school_name { "The School of Life" }
    lead_school_urn { Faker::Number.number(digits: 7) }
    cohort_level { "PG" }
  end
end
