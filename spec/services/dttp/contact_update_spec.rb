# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe ContactUpdate do
    describe "#call" do
      let(:trainee) do
        create(:trainee,
               :with_programme_details,
               dttp_id: dttp_id,
               placement_assignment_dttp_id: placement_assignment_dttp_id)
      end

      let(:trainee_creator_dttp_id) { SecureRandom.uuid }
      let(:dttp_id) { SecureRandom.uuid }
      let(:placement_assignment_dttp_id) { SecureRandom.uuid }
      let(:contact_path) { "/contacts(#{dttp_id})" }
      let(:placement_path) { "/dfe_placementassignments(#{placement_assignment_dttp_id})" }

      before do
        allow(AccessToken).to receive(:fetch).and_return("token")
        trainee.degrees << create(:degree)
      end

      context "success" do
        let(:contact_response) { double(code: 204) }
        let(:placement_response) { double(code: 204) }

        it "sends a PATCH request to set values for contacts and dfe_placementassignments" do
          trainee_presenter = Dttp::TraineePresenter.new(trainee: trainee)

          contact_payload = trainee_presenter.contact_update_params(trainee_creator_dttp_id).to_json
          expect(Client).to receive(:patch).with(contact_path, body: contact_payload).and_return(contact_response)

          placement_payload = trainee_presenter.placement_assignment_update_params.to_json
          expect(Client).to receive(:patch).with(placement_path, body: placement_payload).and_return(placement_response)

          described_class.call(trainee: trainee, trainee_creator_dttp_id: trainee_creator_dttp_id)
        end
      end

      context "error" do
        let(:error_body) { "error" }
        let(:contact_response) { double(code: 405, body: error_body) }

        it "raises an error exception" do
          expect(Client).to receive(:patch).and_return(contact_response)
          expect {
            described_class.call(trainee: trainee, trainee_creator_dttp_id: trainee_creator_dttp_id)
          }.to raise_error(Dttp::ContactUpdate::Error, error_body)
        end
      end
    end
  end
end
