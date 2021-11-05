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
      let(:request_url) { "#{Settings.dttp.api_base_url}#{path}" }

      before do
        enable_features(:persist_to_dttp)
        allow(SubmissionReadyForm).to receive(:new).and_return(double(valid?: true))
        allow(AccessToken).to receive(:fetch).and_return("token")
        stub_request(:post, request_url).to_return(http_response)
        allow(Dttp::OdataParser).to receive(:entity_id).with(trainee.id, HTTParty::Response).and_return(expected_dormant_id)
        allow(Params::Dormancy).to receive(:new).with(trainee: trainee)
          .and_return(double(to_json: expected_params))
      end

      subject { described_class.call(trainee: trainee) }

      context "success" do
        let(:http_response) { { status: 204 } }

        it "sends a POST request to create entity property 'dfe_dormantperiods'" do
          expect(Client).to receive(:post).with(path, body: expected_params).and_call_original
          subject
        end

        it "sets the trainee's dormancy_dttp_id" do
          expect {
            subject
            trainee.reload
          }.to change {
            trainee.dormancy_dttp_id
          }.from(nil) .to(expected_dormant_id)
        end
      end

      it_behaves_like "an http error handler"
    end
  end
end
