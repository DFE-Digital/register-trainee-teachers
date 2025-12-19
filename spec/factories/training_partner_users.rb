# frozen_string_literal: true

FactoryBot.define do
  factory :training_partner_user do
    training_partner
    user
  end
end
