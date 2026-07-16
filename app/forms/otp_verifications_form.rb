# frozen_string_literal: true

class OtpVerificationsForm
  include ActiveModel::Model
  include ActionView::Helpers::DateHelper

  validates :code, presence: true
  validate :rate_limit, if: -> { errors.empty? }
  validate :code_is_correct?, if: -> { errors.empty? }

  def initialize(session:, code:)
    @session = session
    @code = code

    @user = User.find_by(email: session[:otp_email])
    @salt = session[:otp_salt]
  end

private

  attr_reader :session, :code, :user, :salt

  def rate_limit
    email = session[:otp_email]
    return if email.blank?
    return unless EmailRateLimiter.call(email: email, scope: :verifications)

    errors.add(:code, "Please wait #{time_ago_in_words(Settings.otp.throttling.verifications.interval.to_i.seconds.from_now)} before trying again")
  end

  # 600 = 10 mins validity
  def code_is_correct?
    return false unless code.present? && user

    if totp.verify(code, drift_behind: 600).blank?
      errors.add(:code, :invalid_code)
    end
  end

  def totp
    ROTP::TOTP.new(user.otp_secret + salt, issuer: "Register")
  end
end
