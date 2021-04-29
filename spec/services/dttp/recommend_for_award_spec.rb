# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe RecommendForAward do
    describe "#call" do
      let(:trainee) do
        create(:trainee, :trn_received, outcome_date: outcome_date, placement_assignment_dttp_id: placement_assignment_dttp_id)
      end

      let(:outcome_date) { Faker::Date.in_date_period }
      let(:placement_assignment_dttp_id) { SecureRandom.uuid }
      let(:path) { "/dfe_placementassignments(#{placement_assignment_dttp_id})" }
      let(:expected_params) { { test: "value" }.to_json }

      before do
        allow(AccessToken).to receive(:fetch).and_return("token")
        allow(Client).to receive(:patch).and_return(dttp_response)
        allow(Params::PlacementOutcomes::Qts)
          .to receive(:new).with(trainee: trainee)
          .and_return(double(to_json: expected_params))
      end

      context "success" do
        let(:dttp_response) { double(code: 204) }
        it_behaves_like "CreateOrUpdateConsistencyCheckJob", RecommendForAward

        it "sends a PATCH request to set entity property 'dfe_datestandardsassessmentpassed'" do
          expect(Client).to receive(:patch).with(path, body: expected_params).and_return(dttp_response)
          described_class.call(trainee: trainee)
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
          }.to raise_error(Dttp::RecommendForAward::Error, "status: #{status}, body: #{body}, headers: #{headers}")
        end
      end
    end
  end
end
