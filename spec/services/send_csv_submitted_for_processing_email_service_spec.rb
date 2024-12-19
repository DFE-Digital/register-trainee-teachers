# frozen_string_literal: true

require "rails_helper"

describe SendCsvSubmittedForProcessingEmailService do
  let(:wait_time) { 30.seconds }
  let(:upload) { create(:bulk_update_trainee_upload, :in_progress) }

  context "when the 'send_emails' feature is enabled", feature_send_emails: true do
    it "sends the csv submitted for processing email" do
      Timecop.freeze do
        expect {
          described_class.call(upload:)
        }.to have_enqueued_job.with(
          "CsvSubmittedForProcessingEmailMailer", "generate", "deliver_now", args: [upload:]
        ).at(wait_time.from_now)
      end
    end
  end

  context "when the 'send_emails' feature is not enabled" do
    it "sends the csv submitted for processing email" do
      Timecop.freeze do
        expect {
          described_class.call(upload:)
        }.not_to have_enqueued_job.with(
          "CsvSubmittedForProcessingEmailMailer", "generate", "deliver_now", args: [upload:]
        ).at(wait_time.from_now)
      end
    end
  end
end
