# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe BatchCreate do
    describe "#call" do
      let(:trainee) { create(:trainee, :with_programme_details) }
      let(:trainee_presenter) { TraineePresenter.new(trainee: trainee) }
      let(:batch_request) { instance_double(BatchRequest) }
      let(:contact_change_set_id) { SecureRandom.uuid }
      let(:contact_entity_id) { SecureRandom.uuid }

      before do
        allow(AccessToken).to receive(:fetch).and_return("token")
        allow(BatchRequest).to receive(:new).and_return(batch_request)
        trainee.degrees << create(:degree)
      end

      it "submits a batch request to create contact and placement assignment entities and updates trainee record" do
        expect(batch_request).to receive(:add_change_set).with(entity: "contacts",
                                                               payload: trainee_presenter.contact_params.to_json).and_return(
                                                                 contact_change_set_id,
                                                               )

        expect(batch_request).to receive(:add_change_set).with(entity: "dfe_placementassignments",
                                                               payload: trainee_presenter.placement_assignment_params(
                                                                 contact_change_set_id,
                                                               ).to_json)

        expect(batch_request).to receive(:submit).and_return("/contacts(#{contact_entity_id})")

        expect { described_class.call(trainee: trainee) }.to change(trainee, :dttp_id)
      end
    end
  end
end
