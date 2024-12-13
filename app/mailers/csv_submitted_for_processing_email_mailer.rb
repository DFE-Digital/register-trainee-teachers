# frozen_string_literal: true

class CsvSubmittedForProcessingEmailMailer < GovukNotifyRails::Mailer
  def generate(upload:)
    set_template(
      Settings.govuk_notify.csv_submitted_for_processing
      .public_send(
        "#{upload.status}_template_id",
      ),
    )

    set_personalisation(
      first_name: upload.submitted_by.first_name,
      email: upload.submitted_by.email,
      file_name: upload.filename,
      file_link: bulk_update_add_trainees_upload_url(upload),
      submitted_at: upload.submitted_at.to_fs(:govuk_date_and_time),
    )

    mail(to: upload.submitted_by.email)
  end
end
