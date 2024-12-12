# frozen_string_literal: true

class SendCsvSubmittedForProcessingEmailService
  include ServicePattern
  include Rails.application.routes.url_helpers

  def initialize(upload:)
    @upload = upload
  end

  def call
    return unless FeatureService.enabled?(:send_emails)

    CsvSubmittedForProcessingEmailMailer.generate(
      first_name: upload.submitted_by.first_name,
      email: upload.submitted_by.email,
      file_name: upload.file.name,
      file_link: bulk_update_add_trainees_upload_url(upload),
      submitted_at: upload.submitted_at.to_fs(:govuk_date_and_time),
    ).deliver_later
  end

private

  attr_reader :upload
end
