# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe Defer do
    describe "#call" do
      let(:trainee) do
        create(:trainee, :trn_received, placement_assignment_dttp_id: placement_assignment_dttp_id)
      end
      let(:placement_assignment_dttp_id) { SecureRandom.uuid }
      let(:path) { "/dfe_placementassignments(#{placement_assignment_dttp_id})" }

      before do
        allow(AccessToken).to receive(:fetch).and_return("token")
      end

      context "success" do
        let(:dttp_response) { double(code: 204) }
        let(:expected_body) do
          Dttp::Params::Status.new(
            status: DttpStatuses::DEFERRED,
          ).to_json
        end

        it "sends a PATCH request with status params and transitions trainee to deferred" do
          expect(Client).to receive(:patch).with(path, body: expected_body).and_return(dttp_response)

          described_class.call(trainee: trainee)
          expect(trainee.state).to eq("deferred")
        end
      end

      context "error" do
        let(:error_body) { "error" }
        let(:dttp_response) { double(code: 405, body: error_body) }

        it "raises an error exception and does not transition trainee to deferred" do
          expect(Client).to receive(:patch).and_return(dttp_response)
          expect {
            described_class.call(trainee: trainee)
          }.to raise_error(Dttp::Defer::Error, error_body)
          expect(trainee.state).to eq("trn_received")
        end
      end
    end
  end
end
