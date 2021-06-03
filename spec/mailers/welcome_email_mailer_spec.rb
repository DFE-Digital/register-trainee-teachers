# frozen_string_literal: true

require "rails_helper"

describe WelcomeEmailMailer, type: :mailer do
  context "sending an email to a user" do
    let(:mail) { described_class.generate(first_name: "meow", email: "cat@meow.cat") }
    before { mail }

    it "sends an email with the correct template" do
      expect(mail.govuk_notify_template).to eq(Settings.govuk_notify.welcome_email_template_id)
    end

    it "sends an email to the correct email address" do
      expect(mail.to).to eq(["cat@meow.cat"])
    end

    it "includes the first name in the personalisation" do
      expect(mail.govuk_notify_personalisation).to eq(first_name: "meow")
    end
  end
end
