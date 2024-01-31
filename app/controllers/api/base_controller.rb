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

    def provider
      # TODO: - extract provider via authentication
      @provider ||= Provider.first
    end

    def pagination_per_page
      @pagination_per_page ||= params.fetch(:per_page, 50).to_i
    end

    def page
      @page ||= params.fetch(:page, 1).to_i
    end

    def sort_by
      @sort_by ||= params.fetch(:sort_by, "desc")
    end

    def since
      @since ||= params.fetch(:since, Date.new).to_date
    end

    def academic_cycle
      @academic_cycle ||= AcademicCycle.for_year(params[:academic_cycle]) || AcademicCycle.current
    end
  end
end
