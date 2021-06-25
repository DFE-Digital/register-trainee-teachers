# frozen_string_literal: true

FactoryBot.define do
  factory :course_subjects, class: "CourseSubject" do
    association :course
    association :subject
  end
end
