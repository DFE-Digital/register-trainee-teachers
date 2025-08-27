# frozen_string_literal: true

require "rails_helper"

describe CsvSubmittedForProcessingFirstStageEmailMailer do
  context "sending an email to a user" do
    let(:submitted_at) { 1.day.from_now }
    let(:upload) { create(:bulk_update_trainee_upload, :in_progress, submitted_at:) }
    let(:mail) do
      described_class.generate(
        upload:,
      )
    end

    let(:template_ids) do
      {
        in_progress: "in-progress-uuid",
        succeeded: "succeeded-uuid",
        failed: "failed-uuid",
      }
    end

    %i[in_progress succeeded failed].each do |status|
      context "when the upload status is #{status}" do
        let(:upload) { create(:bulk_update_trainee_upload, status) }

        it "sends an email with the correct template" do
          expect(mail.govuk_notify_template).to eq(template_ids[status])
        end
      end
    end

    it "sends an email to the correct email address" do
      expect(mail.to).to eq([upload.submitted_by.email])
    end

    it "includes the first name in the personalisation" do
      expect(mail.govuk_notify_personalisation[:first_name]).to eq(
        upload.submitted_by.first_name,
      )
    end

    it "includes the file name in the personalisation" do
      expect(mail.govuk_notify_personalisation[:file_name]).to eq(
        upload.filename.to_s,
      )
    end

    it "includes the uploads status link in the personalisation" do
      expect(mail.govuk_notify_personalisation[:status_link]).to eq(
        bulk_update_add_trainees_uploads_url,
      )
    end

    it "includes the submission time in the personalisation" do
      expect(mail.govuk_notify_personalisation[:submitted_at]).to eq(
        upload.submitted_at.to_fs(:govuk_date_and_time),
      )
    end
  end
end
