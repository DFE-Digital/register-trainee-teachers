# frozen_string_literal: true

require "rails_helper"

describe SendPerformanceProfileSubmittedEmailService do
  let(:user) { create(:user, :hei) }
  let(:provider) { user.providers.first }
  let(:submitted_at) { Time.zone.now }

  it "sends the performance profile submitted email" do
    expect {
      described_class.call(provider:, submitted_at:)
    }.to have_enqueued_job.with(
      "PerformanceProfileSubmittedEmailMailer", "generate", "deliver_now", args: [user:, submitted_at:]
    )
  end
end
