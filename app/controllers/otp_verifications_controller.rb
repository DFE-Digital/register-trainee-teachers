# frozen_string_literal: true

class OtpVerificationsController < ApplicationController
  skip_before_action :authenticate
  before_action :set!, only: :create

  helper_method :email

  def show
    render("otp/verify")
  end

  def create
    if resp.error
      flash[:error] = resp.error
      render("otp/verify")
    else
      OtpSignInUser.begin_session!(session)
      redirect_to(root_path, notice: "You are now signed in")
    end
  end

private

  attr_reader :email, :user, :code, :salt

  UserLoginResponse = Struct.new(:error, :user)

  def set!
    @email = session[:email]
    @code  = params[:code]
    @salt  = session[:salt]
    @user  = User.find_by(email:)
  end

  def valid_code?
    # 5mins validity
    totp.verify(code, drift_behind: 300).present?
  end

  def totp
    ROTP::TOTP.new(user.otp_secret + salt, issuer: "Register")
  end

  # Called to check the code the user types
  # in and make sure it’s valid.
  def resp
    if user.blank?
      return UserLoginResponse.new(
        "Oh dear, we could not find an account using that email.
        Contact support@nine.shopping if this issue persists."
      )
    end

    unless valid_code?
      return UserLoginResponse.new("That code’s not right, better luck next time 😬")
    end

    UserLoginResponse.new(nil, user)
  end
end
