# frozen_string_literal: true

FactoryBot.define do
  factory :provider, class: Provider do
    sequence :name do |n|
      "Provider #{n}"
    end
    dttp_id { Dttp::CodeSets::Institutions::MAPPING.values.sample[:entity_id] }
  end
end
