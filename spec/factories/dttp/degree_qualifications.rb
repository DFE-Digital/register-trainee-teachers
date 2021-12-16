# frozen_string_literal: true

FactoryBot.define do
  factory :dttp_degree_qualification, class: "Dttp::DegreeQualification" do
    dttp_id { SecureRandom.uuid }
    contact_dttp_id { SecureRandom.uuid }
    response { create(:api_degree_qualification) }
    state { "importable" }
  end
end
