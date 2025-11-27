# frozen_string_literal: true

module Autocomplete
  class TrainingPartnersController < Autocomplete::ApplicationController
    def index
      return error_response if invalid_query?

      @training_partner_search = TrainingPartnerSearch.call(**args).lead_partners

      render(
        json: {
          lead_partners: @training_partner_search.as_json(only: %i[id name urn ukprn]),
        },
      )
    end

  private

    def args
      {
        query: params[:query],
        limit: params[:limit],
      }.compact
    end

    def invalid_query?
      params[:query].present? && params[:query].length < TrainingPartnerSearch::MIN_QUERY_LENGTH
    end

    def error_response
      render_json_error(
        message: I18n.t("api.errors.bad_request", length: TrainingPartnerSearch::MIN_QUERY_LENGTH),
        status: :bad_request,
      )
    end
  end
end
