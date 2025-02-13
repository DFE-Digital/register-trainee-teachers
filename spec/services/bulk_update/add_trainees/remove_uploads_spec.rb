# frozen_string_literal: true

require "rails_helper"

RSpec.describe BulkUpdate::AddTrainees::RemoveUploads do
  %i[uploaded pending validated in_progress succeeded cancelled failed].each do |status|
    let!("#{status}_upload") { create(:bulk_update_trainee_upload, :with_rows, status) }
  end

  describe "#call" do
    it "removes only the uploaded, failed and cancelled uploads" do
      expect {
        described_class.call
      }.to change { BulkUpdate::TraineeUpload.count }.to(4)
        .and change { BulkUpdate::TraineeUploadRow.count }.to(25)
        .and change { BulkUpdate::RowError.count }.to(0)

      expect(pending_upload.reload).to be_present
      expect(validated_upload.reload).to be_present
      expect(in_progress_upload.reload).to be_present
      expect(succeeded_upload.reload).to be_present
      expect {
        cancelled_upload.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
      expect {
        failed_upload.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
      expect {
        uploaded_upload.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
