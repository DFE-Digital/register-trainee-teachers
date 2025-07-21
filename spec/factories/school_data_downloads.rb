# frozen_string_literal: true

FactoryBot.define do
  factory :school_data_download do
    status { :running }
    started_at { Time.current }

    trait :completed do
      status { :completed }
      completed_at { 5.minutes.from_now }
      schools_created { 100 }
      schools_updated { 200 }
      lead_partners_updated { 50 }
    end

    trait :failed do
      status { :failed }
      completed_at { 2.minutes.from_now }
    end
  end
end
