# frozen_string_literal: true

FactoryBot.define do
  factory :dttp_training_initiative, class: "Dttp::TrainingInitiative" do
    dttp_id { SecureRandom.uuid }
    response {
      create(
        :api_training_initiative,
        dfe_initiativeid: dttp_id,
      )
    }
  end
end
