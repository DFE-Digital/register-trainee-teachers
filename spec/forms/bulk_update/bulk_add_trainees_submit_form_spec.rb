# frozen_string_literal: true

require "rails_helper"

module BulkUpdate
  describe BulkAddTraineesSubmitForm, type: :model do
    subject(:form) { described_class.new(upload:) }

    let(:status) { :validated }
    let(:upload) { create(:bulk_update_trainee_upload, status:) }

    context "when the user attempts to submit an invalid upload" do
      let(:status) { :failed }

      it "does not queue a TraineeRows job and does not change the status of the upload" do
        expect(BulkUpdate::AddTrainees::ImportRowsJob).not_to receive(:perform_later)
        form.save
        expect(upload.reload).to be_failed
      end
    end

    context "when user submits a valid upload" do
      let(:status) { :validated }

      it "queues a TraineeRows job and changed the status of the the upload to `submitted`" do
        expect(BulkUpdate::AddTrainees::ImportRowsJob).to receive(:perform_later)
        form.save
        expect(upload.reload).to be_in_progress
      end
    end
  end
end
