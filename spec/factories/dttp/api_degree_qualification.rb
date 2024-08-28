# frozen_string_literal: true

FactoryBot.define do
  factory :api_degree_qualification, class: Hash do
    dfe_degreequalificationid { SecureRandom.uuid }
    _dfe_contactid_value { SecureRandom.uuid }

    dfe_name { "Bachelor of Science" }
    dfe_degreeenddate { "2017-01-13T00:00:00Z" }
    _dfe_degreesubjectid_value { ::CodeSets::DegreeSubjects::MAPPING.to_a.sample[1][:entity_id] }
    _dfe_degreetypeid_value { ::CodeSets::DegreeTypes::MAPPING.to_a.sample[1][:entity_id] }
    _dfe_awardinginstitutionid_value { ::CodeSets::Institutions::MAPPING.to_a.sample[1][:entity_id] }
    _dfe_classofdegreeid_value { ::CodeSets::Grades::MAPPING.to_a.sample[1][:entity_id] }

    initialize_with { attributes.stringify_keys }
    to_create { |instance| instance }
  end
end
