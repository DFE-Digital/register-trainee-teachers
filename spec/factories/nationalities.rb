# frozen_string_literal: true

FactoryBot.define do
  factory :nationality do
    name { Faker::Nation.unique.nationality }

    trait :british do
      name { Dttp::CodeSets::Nationalities::BRITISH }
    end

    trait :irish do
      name { Dttp::CodeSets::Nationalities::IRISH }
    end

    trait :other do
      name { Dttp::CodeSets::Nationalities::OTHER }
    end
  end
end
