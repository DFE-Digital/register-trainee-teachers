# frozen_string_literal: true

module Dttp
  class RetrieveProviders
    include ServicePattern

    class HttpError < StandardError; end

    MAX_PAGE_SIZE = 25

    HEADERS = {
      "Prefer" => "odata.maxpagesize=#{MAX_PAGE_SIZE}",
    }.freeze

    def initialize(request_uri: nil)
      @request_uri = request_uri.presence || default_page_uri
    end

    def call
      if response.code != 200
        raise HttpError, "status: #{response.code}, body: #{response.body}, headers: #{response.headers}"
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

    def default_page_uri
      "/accounts?$filter=dfe_provider eq true"
    end

    def response_body
      @response_body ||= JSON(response.body)
    end

    def response
      @response ||= Client.get(request_uri, headers: HEADERS)
    end
  end
end
