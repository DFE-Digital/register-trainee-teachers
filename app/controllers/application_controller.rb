# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit

  before_action :enforce_basic_auth, if: -> { BasicAuthenticable.required? }

  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

private

  def enforce_basic_auth
    authenticate_or_request_with_http_basic do |username, password|
      BasicAuthenticable.authenticate(username, password)
    end
  end

  def current_user
    @current_user ||= User.find_by(id: session.dig(:auth_user, "user_id"))
  end

  def authenticated?
    current_user.present?
  end

  def authenticate
    redirect_to personas_path unless authenticated?
  end
end
