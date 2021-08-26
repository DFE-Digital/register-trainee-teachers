# frozen_string_literal: true

class ApplicationMailer < Mail::Notify::Mailer
  GENERIC_NOTIFY_TEMPLATE = "876cb8e8-173d-43ba-86bd-060f611aa452"

  rescue_from Notifications::Client::RequestError do
    email = Email.find(headers["email-log-id"].to_s)
    email.update!(delivery_status: "notify_error")
    raise
  end

  def notify_email(headers)
    headers = headers.merge(rails_mailer: mailer_name, rails_mail_template: action_name)
    view_mail(GENERIC_NOTIFY_TEMPLATE, headers)
  end
end
