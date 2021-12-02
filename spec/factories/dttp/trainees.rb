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
    state { "unprocessed" }
  end
end
