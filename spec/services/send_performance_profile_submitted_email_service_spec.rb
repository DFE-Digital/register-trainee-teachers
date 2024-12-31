# frozen_string_literal: true

require "rails_helper"

describe SendPerformanceProfileSubmittedEmailService do
  let(:user) { create(:user, :hei) }
  let(:provider) { user.providers.first }
  let(:submitted_at) { Time.zone.now }

  context "when the 'send_emails' feature is enabled", feature_send_emails: true do
    it "sends the performance profile submitted email" do
      expect {
        described_class.call(provider:, submitted_at:)
      }.to have_enqueued_job.with(
        "PerformanceProfileSubmittedEmailMailer", "generate", "deliver_now", args: [user:, submitted_at:]
      )
    end
  end

  context "when the 'send_emails' feature is not enabled" do
    it "does not send the performance profile submitted email" do
      expect {
        described_class.call(provider:, submitted_at:)
      }.not_to have_enqueued_job.with(
        "PerformanceProfileSubmittedEmailMailer", "generate", "deliver_now", args: [user:, submitted_at:]
      )
    end
  end
end
