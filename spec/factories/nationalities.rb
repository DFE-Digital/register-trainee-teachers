# frozen_string_literal: true

FactoryBot.define do
  factory :nationality do
    name { ::CodeSets::Nationalities::MAPPING.keys.sample }

    trait :british do
      name { ::CodeSets::Nationalities::BRITISH }
    end

    trait :irish do
      name { ::CodeSets::Nationalities::IRISH }
    end

    trait :french do
      name { ::CodeSets::Nationalities::FRENCH }
    end

    trait :other do
      name { ::CodeSets::Nationalities::OTHER }
    end
  end
end
