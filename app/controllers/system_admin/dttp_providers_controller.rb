# frozen_string_literal: true

module SystemAdmin
  class DttpProvidersController < ApplicationController
    def index
      @providers = filtered_providers.page(params[:page] || 1)
    end

    def show
      @provider = authorize Dttp::Provider.find(params[:id])
    end

  private

    def filtered_providers
      SystemAdmin::Dttp::Providers::Filter.call(providers: find_providers, params: filter_params)
    end

    def find_providers
      authorize ::Dttp::Provider.order(:name)
    end

    def filter_params
      @filter_params ||= params.permit(:text_search).presence
    end
  end
end
