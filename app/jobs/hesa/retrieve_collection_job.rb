# frozen_string_literal: true

module Hesa
  class RetrieveCollectionJob < ApplicationJob
    def perform
      return unless FeatureService.enabled?(:sync_from_hesa)

      request_time = Time.zone.now
      xml_response = Hesa::Client.get(url: url)

      HesaCollectionRequest.create(
        requested_at: request_time,
        collection_reference: collection_reference,
        updates_since: updates_since,
        response_body: xml_response,
      )
    end

    def url
      "#{base_url}#{collection_reference}/#{updates_since}"
    end

    def collection_reference
      Settings.hesa.current_collection_reference
    end

    def base_url
      Settings.hesa.collection_base_url
    end

    def updates_since
      @updates_since ||= HesaCollectionRequest.next_from_date
    end
  end
end
