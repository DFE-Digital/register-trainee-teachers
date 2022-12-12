# frozen_string_literal: true

class OtpController < ApplicationController
  skip_before_action :authenticate
  before_action :set!, only: :create

  def show; end

  def create
    return redirect_to(otp_path, flash: { warning: "We could not find your email. Please try again." }) unless user

    user.generate_otp_secret!
    email_otp!
    redirect_to(otp_verifications_path)
  end

private

  attr_reader :email, :user, :salt

  def email_otp!
    ::OtpMailer.generate(
      name: user.name,
      email: user.email,
      code: otp.now,
    ).deliver_later
  end

  def set!
    @email = session[:email] = params[:email]
    @user = User.find_by(email:)
    @salt = session[:salt] = ROTP::Base32.random(16)
  end

  def otp
    @otp = ROTP::TOTP.new(user.otp_secret + salt, issuer: "Register")
  end
end
