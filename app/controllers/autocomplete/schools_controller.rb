# frozen_string_literal: true

module Autocomplete
  class SchoolsController < Autocomplete::ApplicationController
    def index
      return error_response if invalid_query?

      @school_search = SchoolSearch.call(**args).schools

      render(json: { schools: @school_search.as_json(only: %i[id name urn town postcode]) })
    end

  private

    def args
      {
        query: params[:query],
        limit: params[:limit],
      }.compact
    end

    def invalid_query?
      params[:query].present? && params[:query].length < SchoolSearch::MIN_QUERY_LENGTH
    end

    def error_response
      render_json_error(message: I18n.t("api.errors.bad_request", length: SchoolSearch::MIN_QUERY_LENGTH),
                        status: :bad_request)
    end
  end
end
