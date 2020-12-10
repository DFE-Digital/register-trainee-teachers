# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe RegisterForTrn do
    describe "#call" do
      let(:trainee) { create(:trainee, :with_programme_details) }
      let(:trainee_presenter) { TraineePresenter.new(trainee: trainee) }
      let(:batch_request) { instance_double(BatchRequest) }
      let(:trainee_creator_dttp_id) { SecureRandom.uuid }
      let(:contact_change_set_id) { SecureRandom.uuid }
      let(:contact_entity_id) { SecureRandom.uuid }
      let(:contact_payload) { trainee_presenter.contact_params(trainee_creator_dttp_id).to_json }
      let(:placement_assignment_payload) { trainee_presenter.placement_assignment_params(contact_change_set_id).to_json }

      before do
        allow(AccessToken).to receive(:fetch).and_return("token")
        allow(BatchRequest).to receive(:new).and_return(batch_request)
        trainee.degrees << create(:degree)
      end

      it "submits a batch request to create contact and placement assignment entities and updates trainee record" do
        expect(batch_request).to receive(:add_change_set).with(entity: "contacts",
                                                               payload: contact_payload).and_return(
                                                                 contact_change_set_id,
                                                               )

        expect(batch_request).to receive(:add_change_set).with(entity: "dfe_placementassignments",
                                                               payload: placement_assignment_payload)

        expect(batch_request).to receive(:submit).and_return("/contacts(#{contact_entity_id})")

        expect {
          described_class.call(trainee: trainee, trainee_creator_dttp_id: trainee_creator_dttp_id)
        }.to change(trainee, :dttp_id)
      end
    end
  end
end
