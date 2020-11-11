class ApplicationController < ActionController::Base
  before_action :enforce_basic_auth, if: -> { BasicAuthenticable.required? }

  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

private

  def enforce_basic_auth
    authenticate_or_request_with_http_basic do |username, password|
      BasicAuthenticable.authenticate(username, password)
    end
  end

  def current_user
    @current_user ||= User.find(session[:auth_user][:user_id])
  end

  def authenticated?
    current_user.present?
  end
end
