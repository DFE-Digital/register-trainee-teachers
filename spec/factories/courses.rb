# frozen_string_literal: true

FactoryBot.define do
  factory :course do
    name { PUBLISH_SUBJECT_SPECIALISM_MAPPING.keys.sample }
    code { Faker::Alphanumeric.unique.alphanumeric(number: 4, min_alpha: 1).upcase }
    accredited_body_code { Faker::Alphanumeric.alphanumeric(number: 3).upcase }
    start_date { Time.zone.today }
    level { :primary }
    min_age { 7 }
    max_age { 11 }
    duration_in_years { 1 }
    qualification { %i[qts pgce_with_qts pgde_with_qts pgce pgde].sample }
    course_length { %w[OneYear TwoYears].sample }
    route { TRAINING_ROUTES_FOR_COURSE.keys.sample }
    study_mode { COURSE_STUDY_MODES.keys.sample }

    summary do |builder|
      qualifications = builder.qualification.to_s.gsub("_", " ").upcase.gsub("WITH", "with")
      study_mode = builder.study_mode.to_s.humanize(capitalize: false)
      [qualifications, study_mode].join(" ")
    end

    factory :course_with_subjects do
      study_mode { "full_time" }
      transient do
        subjects_count { 1 }
        subject_names { [] }
      end

      before(:create) do |course, evaluator|
        if evaluator.subject_names.any?
          course.name = evaluator.subject_names.join(" and ")
        end
      end

      after(:create) do |course, evaluator|
        if evaluator.subject_names.any?
          evaluator.subject_names.each do |subject_name|
            course.subjects << create(:subject, name: subject_name)
          end
        else
          create_list(:course_subjects, evaluator.subjects_count, course: course)
        end
      end
    end
  end
end
