# frozen_string_literal: true

module Api
  class SchoolsController < Api::ApplicationController
    def index
      return error_response if invalid_query?

      @schools = SchoolSearch.call(args).specified_schools

      render json: { schools: @schools.as_json(only: %i[id name urn town postcode]) }
    end

  private

    def args
      {
        query: params[:query],
        limit: params[:limit],
        lead_schools_only: lead_schools_only,
      }.compact
    end

    def invalid_query?
      params[:query].present? && params[:query].length < SchoolSearch::MIN_QUERY_LENGTH
    end

    def error_response
      render_json_error(message: I18n.t("api.schools.errors.bad_request", length: SchoolSearch::MIN_QUERY_LENGTH), status: :bad_request)
    end

    def lead_schools_only
      ActiveModel::Type::Boolean.new.cast(params[:lead_school])
    end
  end
end
