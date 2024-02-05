# frozen_string_literal: true

module Api
  class BaseController < ActionController::API
    before_action :check_feature_flag!, :authenticate!

    def not_found
      render(status: :not_found, json: { error: "Not found" })
    end

    def check_feature_flag!
      return if FeatureService.enabled?(:register_api)

      not_found
    end

    def authenticate!
      return if valid_authentication_token?

      render(status: :unauthorized, json: { error: "Unauthorized" })
    end

    def current_provider
      @current_provider ||= auth_token.provider
    end

  private

    def valid_authentication_token?
      auth_token.present? && auth_token.enabled?
    end

    def auth_token
      @auth_token ||= begin
        bearer_token = request.headers["Authorization"]
        raise("Bearer token is blank") if bearer_token.blank?

        AuthenticationToken.authenticate(bearer_token)
      rescue StandardError
        nil
      end
    end
  end
end
