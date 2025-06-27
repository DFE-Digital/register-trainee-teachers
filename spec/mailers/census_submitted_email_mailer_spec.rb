# frozen_string_literal: true

require "rails_helper"

describe CensusSubmittedEmailMailer do
  context "sending an email to a user" do
    let(:user) { create(:user) }
    let(:submitted_at) { Time.zone.local(2025, 1, 12, 12, 30) }
    let(:mail) { described_class.generate(user:, submitted_at:) }

    before { mail }

    it "sends an email with the correct template" do
      expect(mail.govuk_notify_template).to eq(Settings.govuk_notify.census_submitted_email_template_id)
    end

    it "sends an email to the correct email address" do
      expect(mail.to).to eq([user.email])
    end

    it "includes the first name in the personalisation" do
      expect(mail.govuk_notify_personalisation[:first_name]).to eq(user.first_name)
    end

    it "includes the submitted at time in the personalisation" do
      expect(mail.govuk_notify_personalisation[:submitted_at]).to eq("12 January 2025 at 12:30pm")
    end
  end
end
