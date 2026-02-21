# frozen_string_literal: true

require "rails_helper"

describe FeedbackSubmittedMailer do
  let(:mail) do
    described_class.generate(
      satisfaction_level: "Satisfied",
      improvement_suggestion: "More documentation would be helpful",
      name: "Jane Smith",
      email: "user@example.com",
    )
  end

  before { mail }

  it "sends an email with the correct template" do
    expect(mail.govuk_notify_template).to eq(Settings.govuk_notify.feedback_submitted_email_template_id)
  end

  it "sends an email to the configured feedback email" do
    expect(mail.to).to eq([Settings.feedback_email])
  end

  it "includes the satisfaction level in the personalisation" do
    expect(mail.govuk_notify_personalisation[:satisfaction_level]).to eq("Satisfied")
  end

  it "includes the improvement suggestion in the personalisation" do
    expect(mail.govuk_notify_personalisation[:improvement_suggestion]).to eq("More documentation would be helpful")
  end

  it "includes the name in the personalisation" do
    expect(mail.govuk_notify_personalisation[:name]).to eq("Jane Smith")
  end

  it "includes the contact email in the personalisation" do
    expect(mail.govuk_notify_personalisation[:email]).to eq("user@example.com")
  end

  context "when optional fields are blank" do
    let(:mail) do
      described_class.generate(
        satisfaction_level: "Very dissatisfied",
        improvement_suggestion: "Needs work",
        name: nil,
        email: nil,
      )
    end

    it "shows 'Not entered' for blank fields" do
      expect(mail.govuk_notify_personalisation[:name]).to eq("Not entered")
      expect(mail.govuk_notify_personalisation[:email]).to eq("Not entered")
    end
  end
end
