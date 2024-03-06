# frozen_string_literal: true

module Api
  class BaseController < ActionController::API
    include Api::ErrorResponse

    before_action :check_feature_flag!, :authenticate!
    around_action :track_request_metrics

    rescue_from ActiveRecord::RecordNotFound do |e|
      render_not_found(message: "#{e.model}(s) not found")
    end

    rescue_from ActionController::ParameterMissing do
      render(
        json: { errors: ["Request could not be parsed"] },
        status: :unprocessable_entity,
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

  private

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

    def track_request_metrics
      start = Time.zone.now
      Yabeda.register_api.requests_total.increment({})
      yield
      duration = Time.zone.now - start
      Yabeda.register_api.request_duration.measure({}, duration)
    end

    def current_version_class_name
      current_version.gsub(".", "").camelize
    end
  end
end
