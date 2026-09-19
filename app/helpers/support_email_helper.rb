# frozen_string_literal: true

module SupportEmailHelper
  def support_email(name: nil, subject: nil, classes: nil, email: Settings.support_email)
    default_classes = "app-!-overflow-break-word"

    govuk_mail_to(email, name, subject: subject, class: "#{default_classes} #{classes}")
  end
end
