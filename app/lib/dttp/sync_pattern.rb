# frozen_string_literal: true

module Dttp
  module SyncPattern
    MAX_PAGE_SIZE = 5000

    HEADERS = {
      "Prefer" => "odata.maxpagesize=#{SyncPattern::MAX_PAGE_SIZE}",
    }.freeze

    class Error < StandardError; end

    def initialize(request_uri: nil)
      @request_uri = request_uri.presence || default_path
    end

    def call
      {
        items: response_body["value"],
        meta: {
          next_page_url: response_body["@odata.nextLink"],
        },
      }
    end

  private

    attr_reader :request_uri

    def default_path
      raise(NotImplementedError("#default_path must be implemented"))
    end

    def response_body
      @response_body ||= JSON(response.body)
    end

    def response
      @response ||= Client.get(request_uri, headers: SyncPattern::HEADERS)
    end
  end
end
