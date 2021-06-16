# frozen_string_literal: true

FactoryBot.define do
  factory :allocation_subject do
    sequence(:name) { |c| "Allocation Subject #{c}" }
  end
end
