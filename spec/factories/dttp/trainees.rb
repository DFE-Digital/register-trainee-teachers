# frozen_string_literal: true

FactoryBot.define do
  factory :dttp_trainee, class: "Dttp::Trainee" do
    dttp_id { SecureRandom.uuid }
    response {
      {
        contactid: dttp_id,
      }
    }
    state { "unprocessed" }
  end
end
