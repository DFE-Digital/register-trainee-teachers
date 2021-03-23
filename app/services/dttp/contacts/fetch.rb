# frozen_string_literal: true

module Dttp
  module Contacts
    class Fetch
      include ServicePattern

      class HttpError < StandardError; end

      attr_reader :trainee

      def initialize(trainee:)
        @trainee = trainee
      end

      def call
        response = Client.get("/contacts(#{trainee.dttp_id})?")

        if response.code != 200
          raise HttpError, "status: #{response.code}, body: #{response.body}, headers: #{response.headers}"
        end

        Dttp::Contact.new(contact_data: JSON(response.body))
      end
    end
  end
end
