# frozen_string_literal: true

class CsvSubmittedForProcessingEmailMailer < GovukNotifyRails::Mailer
  def generate(first_name:, email:, file_link:, file_name:, submitted_at:)
    set_template(Settings.govuk_notify.csv_submitted_for_processing_template_id)

    set_personalisation(
      first_name:,
      email:,
      file_name:,
      file_link:,
      submitted_at:,
    )

    mail(to: email)
  end
end
