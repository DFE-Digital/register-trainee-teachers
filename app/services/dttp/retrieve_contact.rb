# frozen_string_literal: true

module Dttp
  class RetrieveContact
    include ServicePattern

    class HttpError < StandardError; end

    attr_reader :trainee

    CONTACT_ATTRIBUTE_FILTERS = %w[
      emailaddress1
      firstname
      lastname
      contactid
    ].freeze

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      response = Client.get("/contacts(#{trainee.dttp_id})?$select=#{filters}")
      if response.code != 200
        raise HttpError, "status: #{response.code}, body: #{response.body}, headers: #{response.headers}"
      end

      JSON(response.body)
    end

    def filters
      CONTACT_ATTRIBUTE_FILTERS.join(",")
    end
  end
end
