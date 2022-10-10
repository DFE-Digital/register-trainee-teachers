# frozen_string_literal: true

FactoryBot.define do
  factory :hesa_trn_submission, class: "Hesa::TrnSubmission" do
    payload { nil }
    submitted_at { DateTime.now }
  end
end
