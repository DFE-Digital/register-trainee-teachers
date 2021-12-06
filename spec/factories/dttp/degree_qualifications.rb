# frozen_string_literal: true

FactoryBot.define do
  factory :dttp_degree_qualification, class: "Dttp::DegreeQualification" do
    dttp_id { SecureRandom.uuid }
    contact_dttp_id { SecureRandom.uuid }
    response {
      {
        dfe_degreequalificationid: dttp_id,
        _dfe_contactid_value: contact_dttp_id,
      }
    }
    state { "unprocessed" }
  end
end
