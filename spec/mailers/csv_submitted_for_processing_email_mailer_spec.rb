# frozen_string_literal: true

require "rails_helper"

describe CsvSubmittedForProcessingEmailMailer do
  context "sending an email to a user" do
    let(:mail) do
      described_class.generate(
        first_name: "meow",
        email: "cat@meow.cat",
        file_name: "trainees.csv",
        file_link: "http://www.example.com/trainees/bulk_upload/1",
        submitted_at: DateTime.new(2024, 12, 1, 12),
      )
    end

    before { mail }

    it "sends an email with the correct template" do
      expect(mail.govuk_notify_template).to eq(Settings.govuk_notify.csv_submitted_for_processing_template_id)
    end

    it "sends an email to the correct email address" do
      expect(mail.to).to eq(["cat@meow.cat"])
    end

    it "includes the first name in the personalisation" do
      expect(mail.govuk_notify_personalisation[:first_name]).to eq("meow")
    end

    it "includes the file name in the personalisation" do
      expect(mail.govuk_notify_personalisation[:file_name]).to eq("trainees.csv")
    end

    it "includes the file link in the personalisation" do
      expect(mail.govuk_notify_personalisation[:file_link]).to eq("http://www.example.com/trainees/bulk_upload/1")
    end

    it "includes the submission time in the personalisation" do
      expect(mail.govuk_notify_personalisation[:submitted_at]).to eq("01.12.2024, 12pm")
    end
  end
end
