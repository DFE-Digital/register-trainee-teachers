# frozen_string_literal: true

class FeedbackSubmittedMailer < GovukNotifyRails::Mailer
  def generate(satisfaction_level:, improvement_suggestion:, name:, email:)
    set_template(Settings.govuk_notify.feedback_submitted_email_template_id)

    set_personalisation(
      satisfaction_level: satisfaction_level,
      improvement_suggestion: improvement_suggestion,
      name: name.presence || "Not entered",
      email: email.presence || "Not entered",
    )

    mail(to: Settings.feedback_email)
  end
end
