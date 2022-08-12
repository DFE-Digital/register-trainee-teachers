# frozen_string_literal: true

module Hesa
  class RetrieveJob < ApplicationJob
    def perform(collection_reference:, sync_from_hesa:)
      @collection_reference = collection_reference

      return unless sync_from_hesa

      request_time = Time.zone.now
      xml_response = Hesa::Client.get(url: url)

      Nokogiri::XML::Reader(xml_response).each do |node|
        if node.name == "Student" && node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
          student_node = Nokogiri::XML(node.outer_xml).at("./Student")
          Trainees::CreateFromHesa.call(student_node: student_node, record_source: record_source)
        end
      rescue Trainees::CreateFromHesa::HesaImportError => e
        Sentry.capture_exception(e)
        return save_hesa_request(xml_response, request_time).import_failed!
      end

      save_hesa_request(xml_response, request_time).import_successful!
    end

    def save_hesa_request(_xml_response, _request_time = nil)
      raise(NotImplementedError)
    end

    def url
      raise(NotImplementedError)
    end

    def record_source
      raise(NotImplementedError)
    end
  end
end
