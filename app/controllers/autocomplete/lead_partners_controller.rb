# frozen_string_literal: true

module Autocomplete
  class LeadPartnersController < Autocomplete::ApplicationController
    def index
      return error_response if invalid_query?

      @lead_partner_search = LeadPartnerSearch.call(**args).lead_partners

      render(
        json: {
          lead_partners: @lead_partner_search.as_json(only: %i[id name urn ukprn]),
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
      params[:query].present? && params[:query].length < LeadPartnerSearch::MIN_QUERY_LENGTH
    end

    def error_response
      render_json_error(
        message: I18n.t("api.errors.bad_request", length: LeadPartnerSearch::MIN_QUERY_LENGTH),
        status: :bad_request,
      )
    end
  end
end
