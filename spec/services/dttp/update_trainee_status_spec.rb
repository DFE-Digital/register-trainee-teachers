# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe UpdateTraineeStatus do
    describe "#call" do
      let(:status) {  DttpStatuses::PROSPECTIVE_TRAINEE_TRN_REQUESTED }
      let(:entity_id) { SecureRandom.uuid }
      let(:entity_type) { described_class::CONTACT_ENTITY_TYPE }
      let(:trainee) { create(:trainee, dttp_id: entity_id) }
      let(:dttp_response) { double(code: 204) }
      let(:expected_body) { Params::Status.new(status: status).to_json }
      let(:expected_path) { "/contacts(#{entity_id})" }

      before do
        allow(AccessToken).to receive(:fetch).and_return("token")
      end

      it "sends a PATCH request with status params" do
        allow(CreateOrUpdateConsistencyCheckJob).to receive(:perform_later).and_return(true)
        expect(Client).to receive(:patch).with(expected_path, body: expected_body).and_return(dttp_response)
        described_class.call(status: status, trainee: trainee, entity_type: entity_type)
      end

      it "enqueues the CreateOrUpdateConsistencyJob" do
        allow(Client).to receive(:patch).with(expected_path, body: expected_body).and_return(dttp_response)
        expect {
          described_class.call(status: status, trainee: trainee, entity_type: entity_type)
        }.to have_enqueued_job(CreateOrUpdateConsistencyCheckJob).with(trainee)
      end

      context "when the entity_type is placement_assignment" do
        let(:expected_path) { "/dfe_placementassignments(#{entity_id})" }
        let(:entity_type) { described_class::PLACEMENT_ASSIGNMENT_ENTITY_TYPE }
        let(:trainee) { create(:trainee, placement_assignment_dttp_id: entity_id) }

        it "sends a PATCH request with status params" do
          allow(CreateOrUpdateConsistencyCheckJob).to receive(:perform_later).and_return(true)
          expect(Client).to receive(:patch).with(expected_path, body: expected_body).and_return(dttp_response)

          described_class.call(status: status, trainee: trainee, entity_type: entity_type)
        end
      end

      context "when theres an error" do
        let(:status) { 405 }
        let(:body) { "error" }
        let(:headers) { { foo: "bar" } }
        let(:dttp_response) { double(code: status, body: body, headers: headers) }

        it "raises an error exception" do
          expect(Client).to receive(:patch).and_return(dttp_response)

          expect {
            described_class.call(status: status, trainee: trainee, entity_type: entity_type)
          }.to raise_error(described_class::Error, "status: #{status}, body: #{body}, headers: #{headers}")
        end
      end
    end
  end
end
