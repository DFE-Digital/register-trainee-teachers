# frozen_string_literal: true

FactoryBot.define do
  factory :dttp_placement_assignment, class: "Dttp::PlacementAssignment" do
    transient do
      enabled_training_routes { TRAINING_ROUTE_ENUMS.values - ["hpitt_postgrad"] }
    end

    dttp_id { SecureRandom.uuid }
    contact_dttp_id { SecureRandom.uuid }
    response { create(:api_placement_assignment, dttp_id: dttp_id, contact_dttp_id: contact_dttp_id) }
    state { "unprocessed" }
  end
end
