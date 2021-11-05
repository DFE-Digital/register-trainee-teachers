# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe UpdateTraineeStatus do
    describe "#call" do
      let(:status) {  DttpStatuses::PROSPECTIVE_TRAINEE_TRN_REQUESTED }
      let(:entity_id) { SecureRandom.uuid }
      let(:entity_type) { described_class::CONTACT_ENTITY_TYPE }
      let(:trainee) { create(:trainee, dttp_id: entity_id) }
      let(:http_response) { { status: 204 } }
      let(:expected_body) { Params::Status.new(status: status).to_json }
      let(:expected_path) { "/contacts(#{entity_id})" }
      let(:request_url) { "#{Settings.dttp.api_base_url}#{expected_path}" }

      before do
        enable_features(:persist_to_dttp)
        allow(SubmissionReadyForm).to receive(:new).and_return(double(valid?: true))
        allow(AccessToken).to receive(:fetch).and_return("token")
        stub_request(:patch, request_url).to_return(http_response)
      end

      subject { described_class.call(status: status, trainee: trainee, entity_type: entity_type) }

      it "sends a PATCH request with status params" do
        expect(Client).to receive(:patch).with(expected_path, body: expected_body).and_call_original
        subject
      end

      context "when the entity_type is placement_assignment" do
        let(:expected_path) { "/dfe_placementassignments(#{entity_id})" }
        let(:entity_type) { described_class::PLACEMENT_ASSIGNMENT_ENTITY_TYPE }
        let(:trainee) { create(:trainee, placement_assignment_dttp_id: entity_id) }

        it "sends a PATCH request with status params" do
          expect(Client).to receive(:patch).with(expected_path, body: expected_body).and_call_original

          subject
        end
      end

      it_behaves_like "an http error handler"
    end
  end
end
