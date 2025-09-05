# frozen_string_literal: true

class OtpController < ApplicationController
  skip_before_action :authenticate
  before_action :otp_form
  helper_method :otp_form

  def show; end

  def create
    return render(:show) unless otp_form.valid?

    store_session!
    email_otp!
    redirect_to(otp_verifications_path)
  end

private

  def otp_form
    @otp_form ||= OtpForm.new(session:, email:)
  end

  def email
    @email ||= params.dig(:otp_form, :email)
  end

  def user
    return @user if defined?(@user)

    @user = User.find_by(email: otp_form.email)
  end

  def otp
    @otp ||= ROTP::TOTP.new(user.otp_secret + session[:otp_salt], issuer: "Register")
  end

  def store_session!
    session[:otp_email] = otp_form.email
    session[:otp_salt] = ROTP::Base32.random(16)
  end

  def email_otp!
    return unless user

    user.generate_otp_secret!

    OtpMailer.generate(
      name: user.name,
      email: user.email,
      code: otp.now,
    ).deliver_later
  end
end
