# frozen_string_literal: true

class OtpController < ApplicationController
  skip_before_action :authenticate
  before_action :otp_form
  helper_method :otp_form

  def show; end

  def create
    return render(:show) unless otp_form.valid?

    email_otp! if user
    redirect_to(otp_verifications_path)
  end

private

  def otp_form
    @otp_form ||= ::OtpForm.new(email)
  end

  def email
    @email ||= session[:otp_email] = params.dig(:otp_form, :email)&.strip
  end

  def user
    @user ||= User.find_by(email:)
  end

  def email_otp!
    user.generate_otp_secret!

    salt = session[:otp_salt] = ROTP::Base32.random(16)
    otp = ROTP::TOTP.new(user.otp_secret + salt, issuer: "Register")

    ::OtpMailer.generate(
      name: user.name,
      email: user.email,
      code: otp.now,
    ).deliver_later
  end
end
