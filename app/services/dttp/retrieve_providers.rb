# frozen_string_literal: true

module Dttp
  class RetrieveProviders
    include ServicePattern

    class HttpError < StandardError; end

    MAX_PAGE_SIZE = 25

    HEADERS = {
      "Prefer" => "odata.maxpagesize=#{MAX_PAGE_SIZE}",
    }.freeze

    INSTITUTION_TYPE_IDS = [
      "b5ec33aa-216d-e711-80d2-005056ac45bb", # EBITT
      "b7ec33aa-216d-e711-80d2-005056ac45bb", # EYITT
      "b9ec33aa-216d-e711-80d2-005056ac45bb", # HEI
      "bbec33aa-216d-e711-80d2-005056ac45bb", # ITT Provider - HESA
      "bdec33aa-216d-e711-80d2-005056ac45bb", # ITT Provider - Non-HESA
      "bfec33aa-216d-e711-80d2-005056ac45bb", # NonHEI (data gathered under Scitt process)
      "c1ec33aa-216d-e711-80d2-005056ac45bb", # Non-HESA HEI
    ].freeze

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
      "/accounts?$filter=dfe_provider eq true and (#{institution_type_filter})"
    end

    def institution_type_filter
      Dttp::RetrieveProviders::INSTITUTION_TYPE_IDS.map { |id| "_dfe_institutiontypeid_value eq #{id}" }.join(" or ")
    end

    def response_body
      @response_body ||= JSON(response.body)
    end

    def response
      @response ||= Client.get(request_uri, headers: HEADERS)
    end
  end
end
