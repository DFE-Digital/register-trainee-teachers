# frozen_string_literal: true

require "rails_helper"

RSpec.describe BulkUpdate::AddTrainees::RemoveCancelledAndFailedJob do
  context "when the feature is enabled", feature_bulk_add_trainees: true do
    it "calls the RemoveUploads service" do
      allow(BulkUpdate::AddTrainees::RemoveUploads).to receive(:call)

      subject.perform

      expect(BulkUpdate::AddTrainees::RemoveUploads).to have_received(:call)
    end
  end

  context "when the feature is disabled", feature_bulk_add_trainees: false do
    it "does not call the RemoveUploads service" do
      allow(BulkUpdate::AddTrainees::RemoveUploads).to receive(:call)

      subject.perform

      expect(BulkUpdate::AddTrainees::RemoveUploads).not_to have_received(:call)
    end
  end
end
