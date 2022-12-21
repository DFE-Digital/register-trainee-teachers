# frozen_string_literal: true

class OtpVerificationsForm
  include ActiveModel::Model
  include ActionView::Helpers::DateHelper

  validate :cool_down?
  validates :code, presence: true
  validate :code_is_correct?

  def initialize(session:, code:)
    @session = session
    @code = code

    @user = User.find_by(email: session[:otp_email])
    @salt = session[:otp_salt]
    @attempts = session[:otp_attempts] = session[:otp_attempts] || 0
    @last_attempt = session[:otp_last_attempt] = session[:otp_last_attempt] || Time.zone.now
  end

private

  attr_reader :session, :code, :user, :salt, :attempts, :last_attempt

  # 600 = 10 mins validity
  def code_is_correct?
    return unless code.present? && user

    if totp.verify(code, drift_behind: 600).blank?
      errors.add(:code, :invalid_code)
    end
  end

  def cool_down?
    # Add error message if the user has not yet reached their
    # cool off time.
    if Time.zone.now < (last_attempt + cool_down_time)
      errors.add(:code, cool_down_message)
    # Otherwise incement their attempts and reset the last attempt
    # if they submitted a code
    elsif code.present?
      session[:otp_attempts] += 1
      session[:otp_last_attempt] = Time.zone.now
    end
  end

  def cool_down_message
    @cool_down_message ||= "Please wait #{time_left} before trying again"
  end

  # increase cool off then default to 1 hour
  def cool_down_time
    @cool_down_time ||= ([0, 0, 0, 0, 0, 60, 300, 600][attempts] || 3600).seconds
  end

  def time_left
    @time_left ||=  time_ago_in_words(((last_attempt + cool_down_time) - Time.zone.now).seconds.from_now)
  end

  def totp
    ROTP::TOTP.new(user.otp_secret + salt, issuer: "Register")
  end
end
