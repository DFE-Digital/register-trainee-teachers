# frozen_string_literal: true

module Hesa
  class RetrieveCollectionJob < ApplicationJob
    def perform
      return unless FeatureService.enabled?(:sync_from_hesa)

      request_time = Time.zone.now
      xml_response = Hesa::Client.get(url: url)

      # TODO: when we try to import the trainees we're going to mark
      # the collection success/failure and include any failure in the subsequent run of this job
      # This will prevent a failure here e.g. an error repsonse from incrementing the
      # date and skipping a portion of the updates

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
