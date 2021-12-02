# frozen_string_literal: true

FactoryBot.define do
  factory :dttp_placement_assignment, class: "Dttp::PlacementAssignment" do
    dttp_id { SecureRandom.uuid }
    contact_dttp_id { SecureRandom.uuid }
    response {
      {
        dfe_placementassignmentid: dttp_id,
        _dfe_contactid_value: contact_dttp_id,
      }
    }
    state { "unprocessed" }
  end
end
