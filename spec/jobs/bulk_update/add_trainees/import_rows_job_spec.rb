# frozen_string_literal: true

require "rails_helper"

RSpec.describe BulkUpdate::AddTrainees::ImportRowsJob do
  include ActiveJob::TestHelper

  let(:trainee_upload) { create(:bulk_update_trainee_upload) }

  context "when the feature flag is turned off", "feature_bulk_add_trainees": false do
    describe "#perform" do
      it "does not call the BulkUpdate::AddTrainees::ImportRows service" do
        allow(BulkUpdate::AddTrainees::ImportRows).to receive(:call)

        described_class.perform_now(id: trainee_upload.id)

        expect(BulkUpdate::AddTrainees::ImportRows).not_to have_received(:call)
      end
    end
  end

  context "when the feature flag is turned on", "feature_bulk_add_trainees": true do
    describe "#perform" do
      it "calls the BulkUpdate::AddTrainees::ImportRows service" do
        allow(BulkUpdate::AddTrainees::ImportRows).to receive(:call)

        described_class.perform_now(id: trainee_upload.id)

        expect(BulkUpdate::AddTrainees::ImportRows).to have_received(:call).with(id: trainee_upload.id)
      end
    end
  end
end
