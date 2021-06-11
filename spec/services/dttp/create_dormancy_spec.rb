# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe CreateDormancy do
    describe "#call" do
      let(:trainee) do
        create(:trainee, :trn_received, :with_placement_assignment)
      end

      let(:path) { "/dfe_dormantperiods" }
      let(:expected_params) { { test: "value" }.to_json }
      let(:expected_dormant_id) { SecureRandom.uuid }

      before do
        enable_features(:persist_to_dttp)
        allow(AccessToken).to receive(:fetch).and_return("token")
        allow(Client).to receive(:post).and_return(dttp_response)
        allow(Dttp::OdataParser).to receive(:entity_id).with(trainee.id, dttp_response).and_return(expected_dormant_id)
        allow(Params::Dormancy).to receive(:new).with(trainee: trainee)
          .and_return(double(to_json: expected_params))
      end

      context "success" do
        let(:dttp_response) { double(code: 204) }

        it "sends a POST request to create entity property 'dfe_dormantperiods'" do
          expect(Client).to receive(:post).with(path, body: expected_params).and_return(dttp_response)
          described_class.call(trainee: trainee)
        end

        it "sets the trainee's dormancy_dttp_id" do
          expect {
            described_class.call(trainee: trainee)
            trainee.reload
          }.to change {
            trainee.dormancy_dttp_id
          }.from(nil) .to(expected_dormant_id)
        end
      end

      context "error" do
        let(:status) { 405 }
        let(:body) { "error" }
        let(:headers) { { foo: "bar" } }
        let(:dttp_response) { double(code: status, body: body, headers: headers) }

        it "raises an error exception" do
          expect {
            described_class.call(trainee: trainee)
          }.to raise_error(Dttp::CreateDormancy::Error, "status: #{status}, body: #{body}, headers: #{headers}")
        end
      end
    end
  end
end
