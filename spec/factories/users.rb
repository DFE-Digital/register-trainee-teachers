# frozen_string_literal: true

FactoryBot.define do
  factory :user, class: "User" do
    providers { [build(:provider)] }
    dfe_sign_in_uid { SecureRandom.uuid }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
    dttp_id { SecureRandom.uuid }
    welcome_email_sent_at { Faker::Time.backward(days: 1).utc }

    trait :system_admin do
      providers { [] }
      system_admin { true }
    end

    trait :with_multiple_organisations do
      providers { [build(:provider), build(:provider)] }
      lead_schools { [build(:school, :lead), build(:school, :lead)] }
    end

    trait :with_lead_school_organisation do
      providers { [] }
      lead_schools { [build(:school, :lead)] }
    end
  end
end
