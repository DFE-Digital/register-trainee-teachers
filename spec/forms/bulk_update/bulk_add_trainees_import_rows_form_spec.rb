# frozen_string_literal: true

require "rails_helper"

RSpec.describe BulkUpdate::BulkAddTraineesImportRowsForm, type: :model do
  subject { described_class.new(upload:) }

  context "when the BulkUpdate::TraineeUpload status is 'uploaded'" do
    let(:upload) { create(:bulk_update_trainee_upload) }

    it "changes the BulkUpdate::TraineeUpload status to 'pending'" do
      expect {
        subject.save
      }
      .to change { upload.status }.to("pending")
      .and have_enqueued_job(BulkUpdate::AddTrainees::ImportRowsJob).once.with(upload)
    end
  end

  context "when the BulkUpdate::TraineeUpload status is not 'uploaded'" do
    let(:upload) { create(:bulk_update_trainee_upload, :validated) }

    before do
      allow(BulkUpdate::AddTrainees::ImportRowsJob).to receive(:perform_later)
    end

    it "does not change the BulkUpdate::TraineeUpload status to 'pending'" do
      expect {
        subject.save
      } .to raise_error(RuntimeError, "Invalid transition")

      expect(BulkUpdate::AddTrainees::ImportRowsJob).not_to have_received(:perform_later)
    end
  end
end
