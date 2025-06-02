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

    trait :hei do
      providers { [build(:provider, :hei)] }
    end

    trait :scitt do
      providers { [build(:provider, :scitt)] }
    end

    trait :system_admin do
      providers { [] }
      system_admin { true }
    end

    trait :with_multiple_organisations do
      providers { [build(:provider), build(:provider)] }
      lead_partners { [build(:lead_partner, :school), build(:lead_partner, :school)] }
    end

    trait :with_lead_partner_organisation do
      transient do
        lead_partner_type { :school }
      end

      providers { [] }
      lead_partners { [build(:lead_partner, lead_partner_type)] }
    end

    trait :with_no_organisation_in_db do
      providers { [] }
      lead_partners { [] }
    end

    trait :with_otp_secret do
      after(:build, &:generate_otp_secret!)
    end
  end
end
