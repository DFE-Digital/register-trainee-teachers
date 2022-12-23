# frozen_string_literal: true

class OtpMailer < GovukNotifyRails::Mailer
  self.delivery_method = Rails.configuration.action_mailer.delivery_method

  def generate(name:, email:, code:)
    set_template(Settings.govuk_notify.otp_email_template_id)

    set_personalisation(
      name:,
      code:,
    )

    mail(to: email)
  end
end
