# frozen_string_literal: true

module Dttp
  class SyncProvidersJob < ApplicationJob
    queue_as :dttp

    def perform(request_uri = nil)
      provider_list = Dttp::RetrieveProviders.call(request_uri: request_uri)

      provider_list[:items].each do |provider_hash|
        Dttp::ImportProvider.call(provider_hash: provider_hash)
      end

      Dttp::SyncProvidersJob.perform_later(provider_list[:meta][:next_page_url]) if provider_list[:meta][:next_page_url].present?
    end
  end
end
