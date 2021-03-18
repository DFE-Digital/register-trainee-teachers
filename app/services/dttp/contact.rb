# frozen_string_literal: true

module Dttp
  class Contact
    include ServicePattern

    class HttpError < StandardError; end

    attr_reader :trainee

    CONTACT_ATTRIBUTE_FIELDS = %w[
      emailaddress1
      firstname
      lastname
    ].freeze

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      response = Client.get("/contacts(#{trainee.dttp_id})?$select=#{fields}")
      if response.code != 200
        raise HttpError, "status: #{response.code}, body: #{response.body}, headers: #{response.headers}"
      end

      JSON(response.body)
    end

    def fields
      CONTACT_ATTRIBUTE_FIELDS.join(",")
    end
  end
end
