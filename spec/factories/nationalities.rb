# frozen_string_literal: true

FactoryBot.define do
  factory :nationality do
    name { CodeSets::Nationalities::MAPPING.keys.sample }

    trait :british do
      name { CodeSets::Nationalities::BRITISH }
    end

    trait :irish do
      name { CodeSets::Nationalities::IRISH }
    end

    trait :french do
      name { CodeSets::Nationalities::FRENCH }
    end

    trait :other do
      name { CodeSets::Nationalities::OTHER }
    end

    trait :citizen_of_guinea_bissau do
      name { CodeSets::Nationalities::CITIZEN_OF_GUINEA_BISSAU }
    end
  end
end
