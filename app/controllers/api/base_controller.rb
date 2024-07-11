# frozen_string_literal: true

module Api
  class BaseController < ActionController::API
    include Api::ErrorResponse

    before_action :check_feature_flag!, :authenticate!
    around_action :track_request_metrics

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

    def track_request_metrics
      start = Time.zone.now
      track_total_requests
      begin
        yield
      rescue => ex
        track_unsuccessful_requests(ex)
        raise ex
      ensure
        track_request_duration(start:)
        track_response_size
      end
    end

    def track_total_requests
      Yabeda.register_api.requests_total.increment(tracking_labels)
    end

    def track_unsuccessful_requests(ex)
      labels = tracking_labels.merge(error_code: ex.class.name, error_message: ex.message[0, 100])
      Yabeda.register_api.unsuccessful_requests_total.increment(labels)
    end

    def track_request_duration(start:)
      duration = Time.zone.now - start
      Yabeda.register_api.request_duration.measure(tracking_labels, duration)
    end

    def track_response_size
      response_size = response.body.bytesize
      Yabeda.register_api.response_size.measure(tracking_labels, response_size)
    end

    def tracking_labels
      @tracking_labels ||= {
        method: request.method,
        controller: controller_name,
        action: action_name
      }
    end
  end
end
