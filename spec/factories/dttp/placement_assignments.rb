# frozen_string_literal: true

FactoryBot.define do
  factory :dttp_placement_assignment, class: "Dttp::PlacementAssignment" do
    transient do
      enabled_training_routes { TRAINING_ROUTE_ENUMS.values - ["hpitt_postgrad"] }
    end

    dttp_id { SecureRandom.uuid }
    contact_dttp_id { SecureRandom.uuid }
    response {
      {
        dfe_placementassignmentid: dttp_id,
        _dfe_contactid_value: contact_dttp_id,
        _dfe_routeid_value: Dttp::CodeSets::Routes::MAPPING.select { |key, _values| enabled_training_routes.include?(key) }.values.sample[:entity_id],
      }
    }
    state { "unprocessed" }
  end
end
