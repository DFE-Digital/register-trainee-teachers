# frozen_string_literal: true

FactoryBot.define do
  factory :dttp_school, class: "Dttp::School" do
    sequence :name do |n|
      "School #{n}"
    end
    dttp_id { SecureRandom.uuid }
    urn { Faker::Alphanumeric.alphanumeric(number: 3).upcase }

    trait :active do
      status_code { Dttp::School::STATUS_CODES[:active] }
    end

    trait :new do
      status_code { Dttp::School::STATUS_CODES[:new] }
    end

    trait :inactive do
      status_code { Dttp::School::STATUS_CODES[:inactive] }
    end
  end
end
