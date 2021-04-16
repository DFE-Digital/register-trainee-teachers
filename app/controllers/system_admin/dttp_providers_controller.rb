# frozen_string_literal: true

module SystemAdmin
  class DttpProvidersController < ApplicationController
    def index
      @providers = filtered_providers.page(params[:page] || 1)
    end

    def show
      @provider = authorize Dttp::Provider.find(params[:id])
    end

    def create
      @provider = authorize Provider.create!(provider_params)
      redirect_to provider_path(@provider)
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

    def dttp_provider
      @dttp_provider ||= ::Dttp::Provider.find(params[:dttp_provider_id])
    end

    def provider_params
      dttp_provider.attributes.symbolize_keys.slice(:name, :dttp_id, :ukprn)
    end
  end
end
