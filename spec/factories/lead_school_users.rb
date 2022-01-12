# frozen_string_literal: true

FactoryBot.define do
  factory :lead_school_user do
    association :lead_school, factory: :school
    user
  end
end
