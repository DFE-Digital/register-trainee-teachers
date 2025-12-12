# frozen_string_literal: true

FactoryBot.define do
  factory :funding_upload, class: "SystemAdmin::FundingUpload" do
    funding_type { :training_partner_trainee_summary }
    month { 0 }
    status { :pending }

    trait :provider_payment_schedules do
      csv_data { Rails.root.join("spec/support/fixtures/provider_payment_schedules.csv").read }
      funding_type { :provider_payment_schedule }
    end

    trait :training_partner_payment_schedules do
      csv_data { Rails.root.join("spec/support/fixtures/training_partner_payment_schedules.csv").read }
      funding_type { :training_partner_payment_schedule }
    end

    trait :provider_trainee_summaries do
      csv_data { Rails.root.join("spec/support/fixtures/provider_trainee_summaries.csv").read }
      funding_type { :provider_trainee_summary }
    end

    trait :training_partner_trainee_summaries do
      csv_data { Rails.root.join("spec/support/fixtures/training_partner_trainee_summaries.csv").read }
      funding_type { :training_partner_trainee_summary }
    end

    trait :invalid_provider_payment_schedules do
      csv_data { Rails.root.join("spec/support/fixtures/invalid_provider_payment_schedules.csv").read }
      funding_type { :provider_payment_schedule }
    end

    trait :invalid_provider_trainee_summaries do
      csv_data { Rails.root.join("spec/support/fixtures/invalid_provider_trainee_summaries.csv").read }
      funding_type { :provider_trainee_summary }
    end

    trait :invalid_training_partner_trainee_summaries do
      csv_data { Rails.root.join("spec/support/fixtures/invalid_training_partner_trainee_summaries.csv").read }
      funding_type { :training_partner_trainee_summary }
    end

    trait :invalid_training_partner_payment_schedules do
      csv_data { Rails.root.join("spec/support/fixtures/invalid_training_partner_payment_schedules.csv").read }
      funding_type { :training_partner_payment_schedule }
    end
  end
end
