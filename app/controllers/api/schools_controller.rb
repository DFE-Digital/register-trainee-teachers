# frozen_string_literal: true

module Api
  class SchoolsController < Api::ApplicationController
    def index
      return error_response if invalid_query?

      @schools = SchoolSearch.call(
        query: params[:query],
        limit: params[:limit],
        lead_schools_only: params[:lead_school],
      )

      render json: { schools: @schools.as_json(only: %i[id name urn town postcode]) }
    end

  private

    def invalid_query?
      params[:query].present? && params[:query].length < 3
    end

    def error_response
      render_json_error(message: I18n.t("api.schools.errors.bad_request"), status: :bad_request)
    end
  end
end
