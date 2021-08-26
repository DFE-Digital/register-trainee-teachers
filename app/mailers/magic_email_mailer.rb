# frozen_string_literal: true

class MagicEmailMailer < ApplicationMailer
  def magic_email(user:, token:)
    @token = token
    notify_email(
      to: user.email,
      subject: t("authentication.sign_in.email.subject"),
    )
  end
end
