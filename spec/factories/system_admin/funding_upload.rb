# frozen_string_literal: true

FactoryBot.define do
  factory :funding_upload, class: "SystemAdmin::FundingUpload" do
    funding_type { :lead_school_trainee_summary }
    month { 0 }
    status { :pending }

    trait :processed do
      status { :processed }
    end

    trait :failed do
      status { :failed }
    end

    trait :provider_payment_schedules do
      csv_data { Rails.root.join("spec/support/fixtures/provider_payment_schedules.csv").read }
      funding_type { :provider_payment_schedule }
    end

    trait :lead_school_payment_schedules do
      csv_data { Rails.root.join("spec/support/fixtures/lead_school_payment_schedules.csv").read }
      funding_type { :lead_school_payment_schedule }
    end

    trait :provider_trainee_summaries do
      csv_data { Rails.root.join("spec/support/fixtures/provider_trainee_summaries.csv").read }
      funding_type { :provider_trainee_summary }
    end

    trait :lead_school_trainee_summaries do
      csv_data { Rails.root.join("spec/support/fixtures/lead_school_trainee_summaries.csv").read }
      funding_type { :lead_school_trainee_summary }
    end

    trait :invalid_provider_payment_schedules do
      csv_data { Rails.root.join("spec/support/fixtures/invalid_provider_payment_schedules.csv").read }
      funding_type { :provider_payment_schedule }
    end

    trait :invalid_provider_trainee_summaries do
      csv_data { Rails.root.join("spec/support/fixtures/invalid_provider_trainee_summaries.csv").read }
      funding_type { :provider_trainee_summary }
    end

    trait :invalid_lead_school_trainee_summaries do
      csv_data { Rails.root.join("spec/support/fixtures/invalid_lead_school_trainee_summaries.csv").read }
      funding_type { :lead_school_trainee_summary }
    end

    trait :invalid_lead_school_payment_schedules do
      csv_data { Rails.root.join("spec/support/fixtures/invalid_lead_school_payment_schedules.csv").read }
      funding_type { :lead_school_payment_schedule }
    end
  end
end
