# frozen_string_literal: true

module Api
  class BaseController < ActionController::API
    include Api::ValidationsAndErrorHandling
    before_action :check_feature_flag!, :authenticate!

    def check_feature_flag!
      return if FeatureService.enabled?(:register_api)

      render_not_found
    end

    def authenticate!
      return if valid_authentication_token?

      render(status: :unauthorized, json: { error: "Unauthorized" })
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
