# frozen_string_literal: true

module Hesa
  class RetrieveCollectionJob < ApplicationJob
    def perform(from_date: HesaCollectionRequest.next_from_date,
                collection_reference: Settings.hesa.current_collection_reference,
                sync_from_hesa: FeatureService.enabled?(:sync_from_hesa))
      @from_date = from_date
      @collection_reference = collection_reference

      return unless sync_from_hesa

      request_time = Time.zone.now
      xml_response = Hesa::Client.get(url: url)

      Nokogiri::XML::Reader(xml_response).each do |node|
        if node.name == "Student" && node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
          Trainees::CreateFromHesa.call(student_node: Nokogiri::XML(node.outer_xml).at("./Student"))
        end
      rescue Trainees::CreateFromHesa::HesaImportError => e
        Sentry.capture_exception(e)
        return save_hesa_request(xml_response, request_time).import_failed!
      end

      save_hesa_request(xml_response, request_time).import_successful!
    end

    def save_hesa_request(xml_response, request_time)
      HesaCollectionRequest.create(
        requested_at: request_time,
        collection_reference: @collection_reference,
        response_body: xml_response,
      )
    end

    def url
      "#{Settings.hesa.collection_base_url}/#{@collection_reference}/#{@from_date}"
    end
  end
end
