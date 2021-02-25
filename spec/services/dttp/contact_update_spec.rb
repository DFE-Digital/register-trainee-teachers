# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe ContactUpdate do
    describe "#call" do
      let(:trainee) do
        create(:trainee,
               :completed,
               dttp_id: contact_dttp_id,
               placement_assignment_dttp_id: placement_assignment_dttp_id)
      end

      let(:contact_dttp_id) { SecureRandom.uuid }
      let(:placement_assignment_dttp_id) { SecureRandom.uuid }
      let(:contact_path) { "/contacts(#{contact_dttp_id})" }
      let(:placement_path) { "/dfe_placementassignments(#{placement_assignment_dttp_id})" }

      let(:contact_payload) { Params::Contact.new(trainee).to_json }
      let(:placement_payload) { Params::PlacementAssignment.new(trainee).to_json }

      before do
        allow(AccessToken).to receive(:fetch).and_return("token")
        trainee.degrees << create(:degree)
      end

      context "success" do
        let(:contact_response) { double(code: 204) }
        let(:placement_response) { double(code: 204) }

        it "sends a PATCH request to update contact and placement assignment entities" do
          expect(Client).to receive(:patch).with(contact_path, body: contact_payload).and_return(contact_response)
          expect(Client).to receive(:patch).with(placement_path, body: placement_payload).and_return(placement_response)

          described_class.call(trainee: trainee)
        end
      end

      context "error" do
        let(:status) { 405 }
        let(:body) { "error" }
        let(:headers) { { foo: "bar" } }
        let(:contact_response) { double(code: status, body: body, headers: headers) }

        it "raises an error exception" do
          expect(Client).to receive(:patch).and_return(contact_response)
          expect {
            described_class.call(trainee: trainee)
          }.to raise_error(Dttp::ContactUpdate::Error, "status: #{status}, body: #{body}, headers: #{headers}")
        end
      end
    end
  end
end
