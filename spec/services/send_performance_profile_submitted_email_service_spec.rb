# frozen_string_literal: true

require "rails_helper"

describe SendPerformanceProfileSubmittedEmailService do
  let(:user) { create(:user, :hei) }
  let(:inactive_user) { create(:user, providers: [provider], discarded_at: Time.zone.now) }
  let(:provider) { user.providers.first }
  let(:submitted_at) { Time.zone.now }

  it "sends the performance profile submitted email" do
    expect {
      described_class.call(provider:, submitted_at:)
    }.to have_enqueued_job.with(
      "PerformanceProfileSubmittedEmailMailer", "generate", "deliver_now", args: [user:, submitted_at:]
    )
  end

  it "does not send an email to an inactive user" do
    expect {
      described_class.call(provider:, submitted_at:)
    }.not_to have_enqueued_job.with(
      "PerformanceProfileSubmittedEmailMailer", "generate", "deliver_now", args: [user: inactive_user, submitted_at: submitted_at]
    )
  end
end
