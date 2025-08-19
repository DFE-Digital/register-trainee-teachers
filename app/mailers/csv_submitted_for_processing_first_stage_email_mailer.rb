# frozen_string_literal: true

class CsvSubmittedForProcessingFirstStageEmailMailer < GovukNotifyRails::Mailer
  def generate(upload:)
    set_template(
      Settings.govuk_notify.csv_submitted_for_processing_first_stage
      .public_send(
        "#{upload.status}_template_id",
      ),
    )

    set_personalisation(
      first_name: upload.submitted_by.first_name,
      file_name: upload.filename,
      status_link: bulk_update_add_trainees_uploads_url,
      submitted_at: upload.submitted_at.to_fs(:govuk_date_and_time),
    )

    mail(to: upload.submitted_by.email)
  end
end
