# frozen_string_literal: true

FactoryBot.define do
  factory :dttp_trainee, class: "Dttp::Trainee" do
    transient do
      dttp_id_for_provider { provider&.dttp_id || SecureRandom.uuid }
      api_trainee_hash { create(:api_trainee) }
    end
    dttp_id { SecureRandom.uuid }
    response { api_trainee_hash.merge(dttp_id: dttp_id, provider_dttp_id: dttp_id_for_provider) }
    state { "importable" }

    trait :with_placement_assignment do
      placement_assignments { [build(:dttp_placement_assignment, provider_dttp_id: dttp_id_for_provider, contact_dttp_id: dttp_id)] }
    end

    trait :with_early_years_route do
      placement_assignments { [build(:dttp_placement_assignment, provider_dttp_id: dttp_id_for_provider, response: create(:api_placement_assignment, enabled_training_routes: EARLY_YEARS_TRAINING_ROUTES.keys), contact_dttp_id: dttp_id)] }
    end

    trait :with_hpitt_placement_assignment do
      placement_assignments { [build(:dttp_placement_assignment, provider_dttp_id: dttp_id_for_provider, response: create(:api_placement_assignment, enabled_training_routes: ["hpitt_postgrad"]), contact_dttp_id: dttp_id)] }
    end

    trait :with_provider do
      provider
    end
  end
end
