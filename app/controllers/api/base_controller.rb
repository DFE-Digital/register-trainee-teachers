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
      @current_provider ||= Provider.first
    end

  private

    def valid_authentication_token?
      # TODO: Replace this with a proper authentication check
      request.headers["Authorization"] == "Bearer bat"
    end

    def current_provider
      # TODO: - extract provider via authentication
      @current_provider ||= Provider.first
    end
  end
end
