# frozen_string_literal: true

FactoryBot.define do
  factory :dttp_school, class: "Dttp::School" do
    sequence :name do |n|
      "School #{n}"
    end
    dttp_id { SecureRandom.uuid }
    urn { Faker::Alphanumeric.alphanumeric(number: 3).upcase }
  end
end
