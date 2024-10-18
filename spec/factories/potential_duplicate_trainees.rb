# frozen_string_literal: true

FactoryBot.define do
  factory :potential_duplicate_trainee do
    group_id { SecureRandom.uuid }
    trainee
  end
end
