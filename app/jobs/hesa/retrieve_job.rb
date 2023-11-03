# frozen_string_literal: true

module Hesa
  class RetrieveJob < ApplicationJob
    queue_as :hesa

    def perform(collection_reference:, sync_from_hesa:)
      @collection_reference = collection_reference

      return unless sync_from_hesa

      request_time = Time.zone.now
      xml_response = Hesa::Client.get(url:)

      Nokogiri::XML::Reader(xml_response).each do |node|
        next unless node.name == "Student" && node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT

        student_node = Nokogiri::XML(node.outer_xml).at("./Student")
        hesa_trainee = Parsers::IttRecord.to_attributes(student_node:)
        CreateFromHesaJob.perform_later(hesa_trainee:, record_source:)
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
