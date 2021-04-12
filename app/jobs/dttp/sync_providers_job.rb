# frozen_string_literal: true

module Dttp
  class SyncProvidersJob < ApplicationJob
    queue_as :dttp

    PROVIDER_KEYS = {
      "name" => :name,
      "dfe_ukprn" => :ukprn,
      "accountid" => :dttp_id,
    }.freeze

    def perform(request_uri = nil)
      @provider_list = Dttp::RetrieveProviders.call(request_uri: request_uri)

      Dttp::Provider.upsert_all(attributes_for_upsert, unique_by: :dttp_id)

      Dttp::SyncProvidersJob.perform_later(next_page_url) if has_next_page?
    end

  private

    def attributes_for_upsert
      @provider_list[:items].map do |items|
        items.slice(*PROVIDER_KEYS.keys).transform_keys { |item| PROVIDER_KEYS[item] }
      end
    end

    def next_page_url
      @provider_list[:meta][:next_page_url]
    end

    def has_next_page?
      next_page_url.present?
    end
  end
end
