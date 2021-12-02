# frozen_string_literal: true

FactoryBot.define do
  factory :api_placement_assignment, class: Hash do
    dfe_placementassignmentid { SecureRandom.uuid }
    _dfe_contactid_value { SecureRandom.uuid }
    _dfe_ittsubject1id_value { Dttp::CodeSets::CourseSubjects::MAPPING.to_a.sample[1][:entity_id] }
    _dfe_ittsubject2id_value { Dttp::CodeSets::CourseSubjects::MAPPING.to_a.sample[1][:entity_id] }
    _dfe_ittsubject3id_value { Dttp::CodeSets::CourseSubjects::MAPPING.to_a.sample[1][:entity_id] }
    dfe_programmestartdate { Faker::Date.in_date_period(month: 9) }
    dfe_programmeeenddate { Faker::Date.in_date_period(month: 8, year: Faker::Date.in_date_period.year + 1) }
    dfe_commencementdate { Faker::Date.between(from: dfe_programmestartdate, to: dfe_programmeeenddate) }
    _dfe_coursephaseid_value { Dttp::CodeSets::AgeRanges::MAPPING.to_a.sample[1][:entity_id] }
    _dfe_studymodeid_value { Dttp::CodeSets::CourseStudyModes::MAPPING.to_a.sample[1][:entity_id] }

    initialize_with { attributes.stringify_keys }
    to_create { |instance| instance }
  end
end
