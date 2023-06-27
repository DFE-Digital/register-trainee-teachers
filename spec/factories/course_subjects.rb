# frozen_string_literal: true

FactoryBot.define do
  factory :course_subjects, class: "CourseSubject" do
    course
    subject
  end
end
