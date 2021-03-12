# frozen_string_literal: true

module Dttp
  class RetrieveAccount
    include ServicePattern

    class HttpError < StandardError; end

    attr_reader :provider

    ACCOUNT_ATTRIBUTE_FIELDS = %w[
      name
    ].freeze

    def initialize(provider:)
      @provider = provider
    end

    def call
      response = Client.get("/accounts(#{provider.dttp_id})?$select=#{fields}")
      if response.code != 200
        raise HttpError, "status: #{response.code}, body: #{response.body}, headers: #{response.headers}"
      end

      JSON(response.body)
    end

    def fields
      ACCOUNT_ATTRIBUTE_FIELDS.join(",")
    end
  end
end
