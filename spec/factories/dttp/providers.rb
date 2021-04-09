# frozen_string_literal: true

FactoryBot.define do
  factory :dttp_provider, class: "Dttp::Provider" do
    sequence :name do |n|
      "Provider #{n}"
    end
    dttp_id { SecureRandom.uuid }
    ukprn { Faker::Alphanumeric.alphanumeric(number: 3).upcase }
  end
end
