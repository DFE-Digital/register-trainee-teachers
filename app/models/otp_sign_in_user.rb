# frozen_string_literal: true

class OtpSignInUser
  attr_reader :email

  def initialize(email:)
    @email = email&.downcase
  end

  def self.begin_session!(session)
    session[:otp_sign_in_user] = {
      email: session[:otp_email],
      last_active_at: Time.zone.now,
    }.with_indifferent_access

    session.delete(:otp_email)
    session.delete(:otp_salt)
  end

  def self.load_from_session(session)
    otp_sign_in_session = session[:otp_sign_in_user]
    return unless otp_sign_in_session
    return if otp_sign_in_session[:last_active_at] < 2.hours.ago

    otp_sign_in_session[:last_active_at] = Time.zone.now

    new(email: otp_sign_in_session[:email])
  end

  def self.end_session!(session)
    session.destroy
  end

  def user
    return if email.blank?

    if defined?(@user)
      @user
    else
      @user = User.kept.find_by(
        "LOWER(email) = ?",
        email&.downcase,
      )
    end
  end

  def system_admin?
    !!user&.system_admin?
  end

  def end_session!
    session.destroy
  end

  def logout_url
    "/"
  end
end
