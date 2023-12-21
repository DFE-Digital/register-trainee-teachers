# frozen_string_literal: true

class OtpVerificationsForm
  include ActiveModel::Model
  include ThrottleRequests

  validates :code, presence: true
  validate :code_is_correct?

  def initialize(session:, code:)
    @session = session
    @code = code

    @user = User.find_by(email: session[:otp_email])
    @salt = session[:otp_salt]

    super(session:)
  end

private

  attr_reader :session, :code, :user, :salt

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

  def raise_throttle_error
    errors.add(:code, cool_down_message)
  end
end
