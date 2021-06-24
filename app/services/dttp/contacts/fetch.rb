# frozen_string_literal: true

module Dttp
  module Contacts
    class Fetch
      include ServicePattern

      def initialize(dttp_id:)
        @dttp_id = dttp_id
      end

      def call
        Dttp::Contact.new(contact_data: JSON(response.body))
      end

    private

      attr_reader :dttp_id

      def response
        @response ||= Client.get("/contacts(#{dttp_id})?")
      end
    end
  end
end
