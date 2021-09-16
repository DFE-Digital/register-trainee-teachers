# frozen_string_literal: true

FactoryBot.define do
  factory :funding_method_subject do
    funding_method
    allocation_subject
  end
end
