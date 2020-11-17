# frozen_string_literal: true

FactoryBot.define do
  factory :trainee_disability do
    association :trainee
    association :disability
  end
end
