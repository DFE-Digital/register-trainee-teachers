# frozen_string_literal: true

FactoryBot.define do
  factory :lead_school_user do
    lead_school factory: %i[school]
    user
  end
end
