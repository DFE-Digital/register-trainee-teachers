# frozen_string_literal: true

class OtpVerificationsController < ApplicationController
  skip_before_action :authenticate

  before_action :otp_verifications_form
  helper_method :otp_verifications_form

  def show
    render("otp/verify")
  end

  def create
    if otp_verifications_form.valid?
      ::OtpSignInUser.begin_session!(session)
      session[:otp_attempts] = 0
      redirect_to(root_path)
    else
      render("otp/verify")
    end
  end

private

  def otp_verifications_form
    @otp_verifications_form ||= ::OtpVerificationsForm.new(
      session:,
      code:,
    )
  end

  def code
    params.dig(:otp_verifications_form, :code)&.strip
  end
end
