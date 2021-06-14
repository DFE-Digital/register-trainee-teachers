# frozen_string_literal: true

module Dttp
  class SyncProvidersJob < ApplicationJob
    queue_as :dttp

    def perform(request_uri = nil)
      return unless FeatureService.enabled?(:sync_from_dttp)

      @provider_list = Dttp::RetrieveProviders.call(request_uri: request_uri)

      Dttp::Provider.upsert_all(provider_attributes, unique_by: :dttp_id)

      Dttp::SyncProvidersJob.perform_later(next_page_url) if has_next_page?
    end

  private

    attr_reader :provider_list

    def provider_attributes
      Dttp::Parsers::Account.to_provider_attributes(providers: provider_list[:items])
    end

    def next_page_url
      provider_list[:meta][:next_page_url]
    end

    def has_next_page?
      next_page_url.present?
    end
  end
end
