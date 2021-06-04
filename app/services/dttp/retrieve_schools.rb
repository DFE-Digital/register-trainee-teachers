# frozen_string_literal: true

module Dttp
  class RetrieveSchools
    include ServicePattern

    class Error < StandardError; end

    MAX_PAGE_SIZE = 5000

    HEADERS = {
      "Prefer" => "odata.maxpagesize=#{MAX_PAGE_SIZE}",
    }.freeze

    FILTER = {
      "$filter" => "dfe_provider eq false",
    }.freeze

    SELECT = {
      "$select" => %w[
        name
        dfe_urn
        accountid
      ].join(","),
    }.freeze

    QUERY = FILTER.merge(SELECT).to_query

    DEFAULT_PATH = "/accounts?#{QUERY}"

    def initialize(request_uri: nil)
      @request_uri = request_uri.presence || DEFAULT_PATH
    end

    def call
      if response.code != 200
        raise Error, "status: #{response.code}, body: #{response.body}, headers: #{response.headers}"
      end

      {
        items: response_body["value"],
        meta: {
          next_page_url: response_body["@odata.nextLink"],
        },
      }
    end

  private

    attr_reader :request_uri

    def response_body
      @response_body ||= JSON(response.body)
    end

    def response
      @response ||= Client.get(request_uri, headers: HEADERS)
    end
  end
end
