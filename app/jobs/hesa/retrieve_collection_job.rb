# frozen_string_literal: true

module Hesa
  class RetrieveCollectionJob < ApplicationJob
    def perform
      return unless FeatureService.enabled?(:sync_from_hesa)

      request_time = Time.zone.now
      xml_response = Hesa::Client.get(url: url)

      Nokogiri::XML(xml_response).root.children.each do |student_node|
        trainee, ukprn = Trainees::CreateFromHesa.call(student_node: student_node)
        if trainee.invalid?
          Sentry.capture_message("HESA import failed (errors: #{trainee.errors.full_messages}), (ukprn: #{ukprn})")
          return save_hesa_request(xml_response, request_time).import_failed!
        end
      end

      save_hesa_request(xml_response, request_time).import_successful!
    end

    def save_hesa_request(xml_response, request_time)
      HesaCollectionRequest.create(
        requested_at: request_time,
        collection_reference: collection_reference,
        updates_since: updates_since,
        response_body: xml_response,
      )
    end

    def url
      "#{Settings.hesa.collection_base_url}/#{collection_reference}/#{updates_since}"
    end

    def collection_reference
      Settings.hesa.current_collection_reference
    end

    def updates_since
      @updates_since ||= HesaCollectionRequest.next_from_date
    end
  end
end
