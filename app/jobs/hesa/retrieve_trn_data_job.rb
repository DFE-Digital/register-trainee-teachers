# frozen_string_literal: true

module Hesa
  class RetrieveTrnDataJob < RetrieveJob
    def perform(collection_reference: Settings.hesa.current_collection_reference,
                sync_from_hesa: FeatureService.enabled?("hesa_import.sync_trn_data"))
      super
    end

    def save_hesa_request(xml_response, _)
      TrnRequest.create(collection_reference: @collection_reference, response_body: xml_response)
    end

    def url
      "#{Settings.hesa.trn_data_base_url}/#{@collection_reference}/Latest"
    end

    def record_source
      RecordSources::HESA_TRN_DATA
    end
  end
end
