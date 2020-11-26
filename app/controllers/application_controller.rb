# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate

  include Pundit
  before_action :enforce_basic_auth, if: -> { BasicAuthenticable.required? }

  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

private

  def enforce_basic_auth
    authenticate_or_request_with_http_basic do |username, password|
      BasicAuthenticable.authenticate(username, password)
    end
  end

  def dfe_sign_in_user
    @dfe_sign_in_user ||= DfESignInUser.load_from_session(session)
  end

  def current_user
    @current_user ||= User.find_by(email: dfe_sign_in_user&.email)
  end

  def authenticated?
    current_user.present?
  end

  def authenticate
    redirect_to sign_in_index_path unless authenticated?
  end
end
