# frozen_string_literal: true

FactoryBot.define do
  factory :course do
    sequence(:name) { |c| "Course #{c}" }
    code { Faker::Alphanumeric.alphanumeric(number: 4).upcase }
    accredited_body_code { Faker::Alphanumeric.alphanumeric(number: 3).upcase }
    start_date { Time.zone.today }
    level { :primary }
    min_age { 7 }
    max_age { 11 }
    duration_in_years { 1 }
    qualification { %i[qts pgce_with_qts pgde_with_qts pgce pgde].sample }
    course_length { %w[OneYear TwoYears].sample }
    route { TRAINING_ROUTES_FOR_COURSE.keys.sample }
    subjects { [association(:subject)] }

    summary do |builder|
      qualifications = builder.qualification.to_s.gsub("_", " ").upcase.gsub("WITH", "with")
      time = ["full time", "part time"].sample
      [qualifications, time].join(" ")
    end

    factory :course_with_subjects do
      transient do
        subjects_count { 1 }
      end

      after(:create) do |course, evaluator|
        create_list(:course_subjects, evaluator.subjects_count, course: course)
      end
    end
  end
end
