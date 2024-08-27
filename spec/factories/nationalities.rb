# frozen_string_literal: true

FactoryBot.define do
  factory :nationality do
    name { Register::CodeSets::Nationalities::MAPPING.keys.sample }

    trait :british do
      name { Register::CodeSets::Nationalities::BRITISH }
    end

    trait :irish do
      name { Register::CodeSets::Nationalities::IRISH }
    end

    trait :french do
      name { Register::CodeSets::Nationalities::FRENCH }
    end

    trait :other do
      name { Register::CodeSets::Nationalities::OTHER }
    end
  end
end
