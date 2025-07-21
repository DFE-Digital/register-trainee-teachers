# frozen_string_literal: true

FactoryBot.define do
  factory :school_data_download do
    status { :pending }
    started_at { Time.current }
    source { "automated_import" }

    trait :downloading do
      status { :downloading }
    end

    trait :filtering_complete do
      status { :filtering_complete }
      rows_processed { 50_000 }
      rows_filtered { 15_000 }
    end

    trait :processing do
      status { :processing }
      rows_processed { 50_000 }
      rows_filtered { 15_000 }
    end

    trait :completed do
      status { :completed }
      completed_at { 5.minutes.from_now }
      rows_processed { 50_000 }
      rows_filtered { 15_000 }
      schools_created { 100 }
      schools_updated { 200 }
      lead_partners_updated { 50 }
    end

    trait :failed do
      status { :failed }
      completed_at { 2.minutes.from_now }
      error_message { "Network timeout occurred" }
    end
  end
end
