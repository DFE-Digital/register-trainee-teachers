# frozen_string_literal: true

module Dttp
  class RetrieveProviders
    include ServicePattern

    class Error < StandardError; end

    MAX_PAGE_SIZE = 5000

    HEADERS = {
      "Prefer" => "odata.maxpagesize=#{MAX_PAGE_SIZE}",
    }.freeze

    INSTITUTION_TYPES = CodeSets::InstitutionTypes::MAPPING.values.flat_map { |institution| "_dfe_institutiontypeid_value eq #{institution[:entity_id]}" }.join(" or ")

    FILTER = {
      "$filter" => "dfe_provider eq true and (#{INSTITUTION_TYPES})",
    }.freeze

    SELECT = {
      "$select" => %w[
        name
        dfe_ukprn
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
