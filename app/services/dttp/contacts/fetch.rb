# frozen_string_literal: true

module Dttp
  module Contacts
    class Fetch
      include ServicePattern

      class HttpError < StandardError; end

      def initialize(contact_entity_id:)
        @contact_entity_id = contact_entity_id
      end

      def call
        response = Client.get("/contacts(#{contact_entity_id})?")

        if response.code != 200
          raise HttpError, "status: #{response.code}, body: #{response.body}, headers: #{response.headers}"
        end

        Dttp::Contact.new(contact_data: JSON(response.body))
      end

    private

      attr_reader :contact_entity_id
    end
  end
end
