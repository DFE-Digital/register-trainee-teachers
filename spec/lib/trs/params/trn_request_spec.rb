# frozen_string_literal: true

require "rails_helper"

RSpec.describe Trs::Params::TrnRequest, type: :model do
  let(:trainee) { create(:trainee) }
  let(:request_id) { "12345" }
  let(:trn_request) { described_class.new(trainee:, request_id:) }

  describe "#to_json" do
    it "returns a JSON representation of the params" do
      expected_json = {
        "requestId" => request_id,
        "person" => {
          "firstName" => trainee.first_names,
          "middleName" => trainee.middle_names,
          "lastName" => trainee.last_name,
          "dateOfBirth" => trainee.date_of_birth.iso8601,
          "emailAddresses" => [trainee.email],
          "nationalInsuranceNumber" => nil,
          "gender" => CodeSets::Trs::GENDER_CODES[trainee.sex.to_sym],
        },
        "identityVerified" => false,
        "oneLoginUserSubject" => nil,
      }.to_json

      expect(trn_request.to_json).to eq(expected_json)
    end
  end
end
