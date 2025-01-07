# frozen_string_literal: true

class PerformanceProfileSubmittedEmailMailer < GovukNotifyRails::Mailer
  def generate(user:, submitted_at:)
    set_template(Settings.govuk_notify.performance_profile_submitted_email_template_id)

    set_personalisation(
      first_name: user.first_name,
      submitted_at: submitted_at.to_fs(:govuk_date_and_time),
    )

    mail(to: user.email)
  end
end
