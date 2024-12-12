# frozen_string_literal: true

require "rails_helper"

describe SendCsvSubmittedForProcessingEmailService do
  include Rails.application.routes.url_helpers

  before do
    enable_features(:send_emails)
    allow(CsvSubmittedForProcessingEmailMailer).to receive_message_chain(:generate, :deliver_later)
    described_class.call(upload:)
  end

  let(:upload) { create(:bulk_update_trainee_upload, :in_progress, submitted_at:) }
  let(:submitted_at) { 1.day.from_now }

  it "sends the csv submitted for processing email" do
    expect(CsvSubmittedForProcessingEmailMailer).to have_received(:generate)
      .with(
        first_name: upload.submitted_by.first_name,
        email: upload.submitted_by.email,
        file_name: upload.file.name,
        file_link: bulk_update_add_trainees_upload_url(upload),
        submitted_at: upload.submitted_at.to_fs(:govuk_date_and_time),
      )
  end
end
