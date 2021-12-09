# frozen_string_literal: true

FactoryBot.define do
  factory :api_placement_assignment, class: Hash do
    transient do
      dttp_id { SecureRandom.uuid }
      contact_dttp_id { SecureRandom.uuid }
      provider_dttp_id { SecureRandom.uuid }
      enabled_training_routes { TRAINING_ROUTE_ENUMS.values - ["hpitt_postgrad"] }
    end
    dfe_placementassignmentid { dttp_id }
    _dfe_contactid_value { contact_dttp_id }
    _dfe_providerid_value { provider_dttp_id }
    _dfe_routeid_value { Dttp::CodeSets::Routes::MAPPING.select { |key, _values| enabled_training_routes.include?(key) }.values.sample[:entity_id] }
    _dfe_ittsubject1id_value { Dttp::CodeSets::CourseSubjects::MAPPING.to_a.sample[1][:entity_id] }
    _dfe_ittsubject2id_value { Dttp::CodeSets::CourseSubjects::MAPPING.to_a.sample[1][:entity_id] }
    _dfe_ittsubject3id_value { Dttp::CodeSets::CourseSubjects::MAPPING.to_a.sample[1][:entity_id] }
    dfe_programmestartdate { Faker::Date.in_date_period(month: 9).strftime("%Y-%m-%d") }
    dfe_programmeeenddate { Faker::Date.in_date_period(month: 8, year: Faker::Date.in_date_period.year + 1).strftime("%Y-%m-%d") }
    dfe_commencementdate { Faker::Date.between(from: dfe_programmestartdate, to: dfe_programmeeenddate).strftime("%Y-%m-%d") }
    _dfe_coursephaseid_value { Dttp::CodeSets::AgeRanges::MAPPING.to_a.sample[1][:entity_id] }
    _dfe_studymodeid_value { Dttp::CodeSets::CourseStudyModes::MAPPING.to_a.sample[1][:entity_id] }
    dfe_trnassessmentdate { dfe_programmestartdate }
    _dfe_traineestatusid_value { "295af972-9e1b-e711-80c7-0050568902d3" }
    _dfe_academicyearid_value { SecureRandom.uuid }

    initialize_with { attributes.stringify_keys }
    to_create { |instance| instance }
  end
end
