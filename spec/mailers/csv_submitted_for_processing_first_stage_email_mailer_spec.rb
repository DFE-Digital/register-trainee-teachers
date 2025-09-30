# frozen_string_literal: true

require "rails_helper"

describe CsvSubmittedForProcessingFirstStageEmailMailer do
  context "sending an email to a user" do
    let(:upload) { create(:bulk_update_trainee_upload, :pending) }
    let(:user) { upload.provider.users.kept.first }
    let(:mail) do
      described_class.generate(
        upload:,
        user:,
      )
    end

    let(:template_ids) do
      {
        pending: "pending-uuid",
        validated: "validated-uuid",
        failed: "failed-uuid",
      }
    end

    %i[pending validated failed].each do |status|
      context "when the upload status is #{status}" do
        let(:upload) { create(:bulk_update_trainee_upload, status) }

        it "sends an email with the correct template" do
          expect(mail.govuk_notify_template).to eq(template_ids[status])
        end
      end
    end

    %i[uploaded in_progress succeeded cancelled].each do |status|
      context "when the upload status is #{status}" do
        let(:upload) { create(:bulk_update_trainee_upload, status) }

        it "does not send an email" do
          %i[govuk_notify_template first_name email file_name created_at].each do |attribute|
            expect(mail.send(attribute)).to be_nil
          end
        end
      end
    end

    it "sends an email to the correct email address" do
      expect(mail.to).to eq([user.email])
    end

    it "includes the first name in the personalisation" do
      expect(mail.govuk_notify_personalisation[:first_name]).to eq(
        user.first_name,
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
        upload.created_at.to_fs(:govuk_date_and_time),
      )
    end
  end
end
