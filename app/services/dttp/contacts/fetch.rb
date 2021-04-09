# frozen_string_literal: true

module Dttp
  module Contacts
    class Fetch
      include ServicePattern

      class HttpError < StandardError; end

      def initialize(dttp_id:)
        @dttp_id = dttp_id
      end

      def call
        response = Client.get("/contacts(#{dttp_id})?")

        if response.code != 200
          raise HttpError, "status: #{response.code}, body: #{response.body}, headers: #{response.headers}"
        end

        Dttp::Contact.new(contact_data: JSON(response.body))
      end

    private

      attr_reader :dttp_id
    end
  end
end
