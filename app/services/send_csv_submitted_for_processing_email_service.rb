# frozen_string_literal: true

class SendCsvSubmittedForProcessingEmailService
  include ServicePattern
  include Rails.application.routes.url_helpers

  def initialize(user:, upload:)
    @user = user
    @upload = upload
  end

  def call
    return unless FeatureService.enabled?(:send_emails)

    CsvSubmittedForProcessingEmailMailer.generate(
      first_name: user.first_name,
      email: user.email,
      file_name: upload.file_name,
      file_link: bulk_update_trainees_upload_url(upload.id),
      submitted_at: upload.created_at.strftime("%d.%M.%Y, %l%p"),
    ).deliver_later
  end

private

  attr_reader :user, :upload
end
