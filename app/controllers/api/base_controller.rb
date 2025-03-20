# frozen_string_literal: true

module Api
  class BaseController < ActionController::API
    include Api::ErrorResponse
    include ApiMonitorable

    before_action :check_feature_flag!, :authenticate!, :update_last_used_at!

    rescue_from ActiveRecord::RecordNotFound do |e|
      render_not_found(message: "#{e.model}(s) not found")
    end

    rescue_from ActionController::ParameterMissing do |e|
      render(
        json: { errors: [e.message.capitalize] },
        status: :unprocessable_entity,
      )
    end

    rescue_from JSON::ParserError do |e|
      render(
        json: { errors: [e.message.capitalize] },
        status: :bad_request,
      )
    end

    rescue_from NotImplementedError do |_e|
      render(
        json: { errors: ["Version '#{current_version}' not available"] },
        status: :bad_request,
      )
    end

    def check_feature_flag!
      return if FeatureService.enabled?(:register_api)

      render_not_found
    end

    def authenticate!
      return if valid_authentication_token?

      render(status: :unauthorized, json: { error: "Unauthorized" })
    end

    def current_provider
      @current_provider ||= auth_token.provider
    end

    def audit_user
      current_provider
    end

    def render_not_found(message: "Not found")
      render(**not_found_response(message:))
    end

    def current_version
      params[:api_version]
    end

    def update_last_used_at!
      return unless valid_authentication_token?

      auth_token.update_last_used_at!
    end

  private

    alias_method :version, :current_version

    def valid_authentication_token?
      auth_token.present? && auth_token.enabled?
    end

    def auth_token
      return @auth_token if defined?(@auth_token)

      bearer_token = request.headers["Authorization"]

      if bearer_token.blank?
        @auth_token = nil
      else
        @auth_token = AuthenticationToken.authenticate(bearer_token)
      end
    end
  end
end
