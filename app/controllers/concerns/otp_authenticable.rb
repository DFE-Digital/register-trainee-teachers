# frozen_string_literal: true

module OtpAuthenticable
  extend ActiveSupport::Concern

  def authenticate_user!
    redirect_to(auth_path) unless current_user
  end

  def user_signed_in?
    current_user.present?
  end

  def current_user
    @current_user ||= lookup_user_by_cookie
  end

  def lookup_user_by_cookie
    User.find(session[:user_id]) if session[:user_id]
  end
end
