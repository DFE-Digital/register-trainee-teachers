# frozen_string_literal: true

FactoryBot.define do
  factory :course_subject do
    association :course
    association :subject
  end
end
