# frozen_string_literal: true

require "rails_helper"

describe SendCsvSubmittedForProcessingFirstStageEmailService do
  let(:wait_time) { 30.seconds }
  let(:upload) { create(:bulk_update_trainee_upload, :in_progress) }
  let(:user) { upload.provider.users.kept.first }

  it "sends the csv submitted for processing email" do
    Timecop.freeze do
      expect {
        described_class.call(upload:)
      }.to have_enqueued_job.with(
        "CsvSubmittedForProcessingFirstStageEmailMailer", "generate", "deliver_now", args: [upload:, user:]
      ).at(wait_time.from_now)
    end
  end
end
