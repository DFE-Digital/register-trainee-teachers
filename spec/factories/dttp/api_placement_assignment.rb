# frozen_string_literal: true

FactoryBot.define do
  factory :api_placement_assignment, class: Hash do
    transient do
      dttp_id { SecureRandom.uuid }
      contact_dttp_id { SecureRandom.uuid }
      provider_dttp_id { SecureRandom.uuid }
      enabled_training_routes { TRAINING_ROUTE_ENUMS.values - EARLY_YEARS_TRAINING_ROUTES.keys - ["hpitt_postgrad"] }
    end
    dfe_placementassignmentid { dttp_id }
    _dfe_contactid_value { contact_dttp_id }
    _dfe_providerid_value { provider_dttp_id }
    _dfe_routeid_value { Dttp::CodeSets::Routes::MAPPING.select { |key, _values| enabled_training_routes.include?(key) }.values.sample[:entity_id] }
    _dfe_ittsubject1id_value { Dttp::CodeSets::CourseSubjects::MAPPING.to_a.sample[1][:entity_id] }
    _dfe_ittsubject2id_value { Dttp::CodeSets::CourseSubjects::MAPPING.to_a.sample[1][:entity_id] }
    _dfe_ittsubject3id_value { Dttp::CodeSets::CourseSubjects::MAPPING.to_a.sample[1][:entity_id] }
    dfe_programmestartdate { Faker::Date.in_date_period(month: ACADEMIC_CYCLE_START_MONTH, year: current_academic_year).strftime("%Y-%m-%d") }
    dfe_programmeeenddate { Faker::Date.in_date_period(month: ACADEMIC_CYCLE_END_MONTH, year: current_academic_year + 1).strftime("%Y-%m-%d") }
    dfe_commencementdate { Faker::Date.between(from: dfe_programmestartdate, to: dfe_programmeeenddate).strftime("%Y-%m-%d") }
    _dfe_coursephaseid_value { AgeRange::MAPPING.to_a.sample[1][:entity_id] }
    _dfe_studymodeid_value { Dttp::CodeSets::CourseStudyModes::MAPPING.to_a.sample[1][:entity_id] }
    _dfe_initiative1id_value { Dttp::CodeSets::TrainingInitiatives::MAPPING[ROUTE_INITIATIVES_ENUMS[:now_teach]][:entity_id] }
    dfe_trnassessmentdate { dfe_programmestartdate }
    _dfe_traineestatusid_value { "295af972-9e1b-e711-80c7-0050568902d3" }
    _dfe_academicyearid_value { SecureRandom.uuid }

    _dfe_awardinginstitutionid_value { Dttp::CodeSets::Institutions::MAPPING.to_a.sample[1][:entity_id] }
    _dfe_subjectofugdegreeid_value { Dttp::CodeSets::DegreeSubjects::MAPPING.to_a.sample[1][:entity_id] }
    _dfe_firstdegreeorequivalentid_value { Dttp::CodeSets::DegreeOrEquivalentQualifications::MAPPING.to_a.sample[1][:entity_id] }
    _dfe_classofugdegreeid_value { Dttp::CodeSets::Grades::MAPPING.to_a.sample[1][:entity_id] }
    _dfe_overseastrainedteachercountryid_value { nil }

    trait :with_non_uk_degree_information do
      _dfe_overseastrainedteachercountryid_value { Dttp::CodeSets::Countries::MAPPING.to_a.sample[1][:entity_id] }
    end

    initialize_with { attributes.stringify_keys }
    to_create { |instance| instance }

    trait :with_provider_led_bursary do
      enabled_training_routes { ["provider_led_postgrad"] }
      _dfe_ittsubject1id_value { Dttp::CodeSets::CourseSubjects::MODERN_LANGUAGES_DTTP_ID }
      _dfe_bursarydetailsid_value { Dttp::CodeSets::BursaryDetails::POSTGRADUATE_BURSARY }
    end

    trait :with_early_years_school_direct do
      _dfe_routeid_value { "6d89922e-acc2-e611-80be-00155d010316" }
    end

    trait :with_early_years_salaried_bursary do
      enabled_training_routes { ["early_years_salaried"] }
      _dfe_ittsubject1id_value { Dttp::CodeSets::CourseSubjects::EARLY_YEARS_DTTP_ID }
      _dfe_bursarydetailsid_value { Dttp::CodeSets::BursaryDetails::GRANT }
    end

    trait :with_tiered_bursary do
      enabled_training_routes { ["early_years_postgrad"] }
      _dfe_bursarydetailsid_value { "66671547-33ff-eb11-94ef-00224899ca99" }
    end

    trait :with_provider_led_undergrad do
      enabled_training_routes { ["provider_led_undergrad"] }
    end

    trait :with_future_teaching_scholars_initiative do
      enabled_training_routes { nil }
      _dfe_routeid_value { Dttp::CodeSets::Routes::MAPPING[ROUTE_INITIATIVES_ENUMS[:future_teaching_scholars]][:entity_id] }
    end

    trait :with_scholarship do
      enabled_training_routes { ["provider_led_postgrad"] }
      _dfe_ittsubject1id_value { Dttp::CodeSets::CourseSubjects::MODERN_LANGUAGES_DTTP_ID }
      _dfe_bursarydetailsid_value { Dttp::CodeSets::BursaryDetails::SCHOLARSHIP }
    end

    trait :with_no_bursary_awarded do
      enabled_training_routes { ["pg_teaching_apprenticeship"] }
      _dfe_ittsubject1id_value { Dttp::CodeSets::CourseSubjects::MODERN_LANGUAGES_DTTP_ID }
      _dfe_bursarydetailsid_value { Dttp::CodeSets::BursaryDetails::NO_BURSARY_AWARDED }
    end

    trait :primary_mathematics_specialism do
      _dfe_initiative1id_value do
        [
          Dttp::CodeSets::TrainingInitiatives::PRIMARY_MATHEMATICS_SPECIALISM,
          Dttp::CodeSets::TrainingInitiatives::PRIMARY_GENERAL_WITH_MATHS,
        ].sample
      end
    end
  end
end
