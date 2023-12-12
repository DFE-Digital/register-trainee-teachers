# frozen_string_literal: true

module Api
  class ProvidersController < Api::ApplicationController
    def index
      return error_response if invalid_query?

      @provider_search = ProviderSearch.call(**args).providers

      render(json: { providers: @provider_search.as_json(only: %i[id name code ukprn]) })
    end

  private

    def args
      {
        query: params[:query],
        limit: params[:limit],
      }.compact
    end

    def invalid_query?
      params[:query].present? && params[:query].length < ProviderSearch::MIN_QUERY_LENGTH
    end

    def error_response
      render_json_error(
        message: I18n.t("api.errors.bad_request",
                        length: ProviderSearch::MIN_QUERY_LENGTH),
        status: :bad_request,
      )
    end
  end
end
