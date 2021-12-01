# frozen_string_literal: true

FactoryBot.define do
  factory :dttp_trainee, class: "Dttp::Trainee" do
    provider_dttp_id { SecureRandom.uuid }
    dttp_id { SecureRandom.uuid }
    response {
      {
        contactid: dttp_id,
        _parentcustomerid_value: provider_dttp_id,
      }
    }
    state { "importable" }

    trait :with_placement_assignment do
      placement_assignments { [build(:dttp_placement_assignment, contact_dttp_id: dttp_id)] }
    end
  end
end
