# frozen_string_literal: true

FactoryBot.define do
  factory :user, class: "User" do
    transient do
      providers { [build(:provider)] }
      lead_schools { [] }
    end

    after(:create) do |user, evaluator|
      evaluator.providers.each do |provider|
        create(:provider_user, provider: provider, user: user)
      end

      evaluator.lead_schools.each do |lead_school|
        create(:lead_school_user, lead_school: lead_school, user: user)
      end
    end

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
  end
end
