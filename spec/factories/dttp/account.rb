# frozen_string_literal: true

FactoryBot.define do
  factory :dttp_account, class: "Dttp::Account" do
    sequence :name do |n|
      "Provider #{n}"
    end
    dttp_id { SecureRandom.uuid }
    ukprn { Faker::Number.number(digits: 8) }
    accreditation_id { Faker::Number.number(digits: 4) }
  end
end
