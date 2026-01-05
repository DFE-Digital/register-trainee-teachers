# frozen_string_literal: true

require "rails_helper"

describe AuthenticationTokens::ExpirationReminderMailer do
  describe "#generate" do
    let(:authentication_token) { create(:authentication_token, expires_at: 1.month.from_now) }
    let(:mail) { described_class.generate(authentication_token:) }

    it "sends an email with the correct template" do
      expect(mail.govuk_notify_template).to eq(Settings.govuk_notify.authentication_token_expiration_reminder_template_id)
    end

    it "sends an email to the correct email address" do
      expect(mail.to).to eq([authentication_token.created_by.email])
    end

    it "includes the first name in the personalisation" do
      expect(mail.govuk_notify_personalisation[:first_name]).to eq(authentication_token.created_by.first_name)
    end

    it "includes the expiration period in the personalisation" do
      expect(mail.govuk_notify_personalisation[:expires_in]).to eq("in 1 month")
    end
  end
end
