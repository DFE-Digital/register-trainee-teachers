# frozen_string_literal: true

class SendWelcomeEmailService
  include ServicePattern

  def initialize(user:)
    @user = user
  end

  def call
    return unless FeatureService.enabled?(:send_emails)
    return if user.welcome_email_sent_at
    return unless lead_school_user?

    WelcomeEmailMailer.generate(
      first_name: user.first_name,
      email: user.email,
    ).deliver_later

    user.update!(
      welcome_email_sent_at: Time.zone.now,
    )
  end

private

  attr_reader :user

  def lead_school_user?
    user.lead_schools.any?
  end
end
