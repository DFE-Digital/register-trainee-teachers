# frozen_string_literal: true

module AuthenticationTokens
  class ExpirationReminderMailer < GovukNotifyRails::Mailer
    include TimeHelpers

    def generate(authentication_token:)
      set_template(Settings.govuk_notify.authentication_token_expiration_reminder_template_id)

      set_personalisation(
        first_name: authentication_token.created_by.first_name,
        expires_in: in_exact_time(authentication_token.expires_at),
      )

      mail(to: authentication_token.created_by.email)
    end
  end
end
