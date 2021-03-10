# frozen_string_literal: true

FactoryBot.define do
  factory :provider, class: Provider do
    sequence :name do |n|
      "Provider #{n}"
    end
    dttp_id { SecureRandom.uuid }
    code { Faker::Alphanumeric.alphanumeric(number: 3).upcase }
  end
end
