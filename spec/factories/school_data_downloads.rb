# frozen_string_literal: true

FactoryBot.define do
  factory :school_data_download do
    started_at { Time.current }
    status { :pending }
    schools_created { 0 }
    schools_updated { 0 }

    trait :completed do
      status { :completed }
      completed_at { started_at + 30.minutes }
      file_count { 2 }
      schools_created { 150 }
      schools_updated { 50 }
    end

    trait :failed do
      status { :failed }
      completed_at { started_at + 10.minutes }
      error_message { "Network connection failed" }
    end

    trait :downloading do
      status { :downloading }
    end

    trait :extracting do
      status { :extracting }
    end

    trait :processing do
      status { :processing }
      file_count { 2 }
    end
  end
end
