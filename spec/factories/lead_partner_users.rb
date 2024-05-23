# frozen_string_literal: true

FactoryBot.define do
  factory :lead_partner_user do
    lead_partner
    user
  end
end
