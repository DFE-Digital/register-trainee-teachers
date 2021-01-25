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

        it "sends a PATCH request to set entity property 'dfe_TraineeStatusId@odata.bind' and transitions trainee to deferred" do
          body = { "dfe_TraineeStatusId@odata.bind" => "/dfe_traineestatuses(1d5af972-9e1b-e711-80c7-0050568902d3)" }.to_json
          expect(Client).to receive(:patch).with(path, body: body).and_return(dttp_response)
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
