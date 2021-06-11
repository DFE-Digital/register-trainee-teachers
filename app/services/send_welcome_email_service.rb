# frozen_string_literal: true

class SendWelcomeEmailService
  include ServicePattern

  def initialize(current_user:)
    @current_user = current_user
  end

  def call
    return unless FeatureService.enabled?(:send_emails)
    return if current_user.welcome_email_sent_at

    WelcomeEmailMailer.generate(
      first_name: current_user.first_name,
      email: current_user.email,
    ).deliver_later

    current_user.update!(
      welcome_email_sent_at: Time.zone.now,
    )
  end

private

  attr_reader :current_user
end
