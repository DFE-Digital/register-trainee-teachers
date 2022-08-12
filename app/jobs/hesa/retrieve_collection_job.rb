# frozen_string_literal: true

module Hesa
  class RetrieveCollectionJob < RetrieveJob
    def perform(collection_reference: Settings.hesa.current_collection_reference,
                sync_from_hesa: FeatureService.enabled?("hesa_import.sync_collection"))
      super
    end

    def save_hesa_request(xml_response, request_time)
      CollectionRequest.create(
        requested_at: request_time,
        collection_reference: @collection_reference,
        response_body: xml_response,
      )
    end

    def url
      "#{Settings.hesa.collection_base_url}/#{@collection_reference}/#{CollectionRequest.next_from_date}"
    end

    def record_source
      RecordSources::HESA_COLLECTION
    end
  end
end
