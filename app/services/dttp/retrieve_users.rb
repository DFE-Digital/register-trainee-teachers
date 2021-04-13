# frozen_string_literal: true

module Dttp
  class RetrieveUsers
    include ServicePattern

    class Error < StandardError; end

    MAX_PAGE_SIZE = 5000

    HEADERS = {
      "Prefer" => "odata.maxpagesize=#{MAX_PAGE_SIZE}",
    }.freeze

    SELECT = {
      "$select" => %w[
        firstname
        lastname
        emailaddress1
        contactid
        _parentcustomerid_value
      ].join(",")
    }.freeze

    FILTER = {
      "$filter" => "dfe_portaluser eq true",
     }.freeze

    QUERY = FILTER.merge(SELECT).to_query
    DEFAULT_PATH = "/contacts?#{QUERY}"

    def initialize(path: nil)
      @path = path.presence || DEFAULT_PATH
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

    attr_reader :path

    def response
      @response ||= Client.get(path, headers: HEADERS)
    end

    def response_body
      @response_body ||= JSON(response.body)
    end
  end
end
