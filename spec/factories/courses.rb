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
    study_mode { TRAINEE_STUDY_MODE_ENUMS.keys.sample }
    uuid { SecureRandom.uuid }

    summary do |builder|
      qualifications = builder.qualification.to_s.gsub("_", " ").upcase.gsub("WITH", "with")
      study_mode = builder.study_mode.to_s.humanize(capitalize: false)
      [qualifications, study_mode].join(" ")
    end

    factory :course_with_unmappable_subject do
      transient do
        subjects_count { 1 }
        subject_names { ["Crosby, Stills & Nash studies"] }
        study_mode { "full_time" }
      end

      before(:create) do |course, evaluator|
        course.name = "Unmappable subject course"
        course.study_mode = evaluator.study_mode
      end

      after(:create) do |course, evaluator|
        evaluator.subject_names.each do |subject_name|
          course.subjects << create(:subject, name: subject_name)
        end
      end
    end

    factory :course_with_subjects do
      transient do
        uuid { SecureRandom.uuid }
        subjects_count { 1 }
        subject_names { [] }
        study_mode { "full_time" }
      end

      before(:create) do |course, evaluator|
        if evaluator.subject_names.any?
          course.name = evaluator.subject_names.join(" and ")
        end

        if evaluator.study_mode.present?
          course.study_mode = evaluator.study_mode
        end

        course.uuid = evaluator.uuid
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
