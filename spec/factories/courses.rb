# frozen_string_literal: true

FactoryBot.define do
  factory :course do
    transient do
      age_range do
        DfE::ReferenceData::AgeRanges::AGE_RANGES.all_as_hash.select do |_, v|
          v[:option] == :main && v[:levels]&.include?(level)
        end.keys.sample
      end
    end

    name { PUBLISH_PRIMARY_SUBJECT_SPECIALISM_MAPPING.keys.sample }
    code { Faker::Alphanumeric.unique.alphanumeric(number: 4, min_alpha: 1).upcase }
    accredited_body_code { Faker::Alphanumeric.alphanumeric(number: 3).upcase }
    published_start_date { Time.zone.today }
    level { PUBLISH_PRIMARY_SUBJECT_SPECIALISM_MAPPING.keys.include?(name) ? :primary : :secondary }
    min_age { age_range.first }
    max_age { age_range.last }
    duration_in_years { 1 }
    qualification { %i[qts pgce_with_qts pgde_with_qts pgce pgde].sample }
    course_length { %w[OneYear TwoYears].sample }
    route { TRAINING_ROUTES_FOR_COURSE.keys.sample }
    study_mode { ReferenceData::TRAINEE_STUDY_MODES.names.sample }
    uuid { SecureRandom.uuid }
    recruitment_cycle_year { current_academic_year }

    summary do |builder|
      qualifications = builder.qualification.to_s.gsub("_", " ").upcase.gsub("WITH", "with")
      study_mode = builder.study_mode.to_s.humanize(capitalize: false)
      [qualifications, study_mode].join(" ")
    end

    trait :secondary do
      name { (PUBLISH_SECONDARY_SUBJECT_SPECIALISM_MAPPING.keys - [PublishSubjects::MODERN_LANGUAGES]).sample }
    end

    trait :with_full_time_dates do
      full_time_start_date { Faker::Date.in_date_period(month: ACADEMIC_CYCLE_START_MONTH, year: current_academic_year) }
      full_time_end_date { Faker::Date.in_date_period(month: ACADEMIC_CYCLE_END_MONTH, year: current_academic_year + 1) }
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
        recruitment_cycle_year { Settings.current_recruitment_cycle_year }
      end

      before(:create) do |course, evaluator|
        if evaluator.subject_names.any?
          course.name = evaluator.subject_names.join(" and ")
        end

        if evaluator.study_mode.present?
          course.study_mode = evaluator.study_mode
        end

        course.uuid = evaluator.uuid
        course.recruitment_cycle_year = evaluator.recruitment_cycle_year
      end

      after(:create) do |course, evaluator|
        if evaluator.subject_names.any?
          evaluator.subject_names.each do |subject_name|
            course.subjects << create(:subject, name: subject_name)
          end
        else
          create_list(:course_subjects, evaluator.subjects_count, course:)
        end
      end
    end
  end
end
