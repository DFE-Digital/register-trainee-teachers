# frozen_string_literal: true

module Dttp
  class RetrieveTrainees
    include ServicePattern
    include SyncPattern

    MAX_PAGE_SIZE = 50
    TRAINEE_CONTACT_TYPE_DTTP_ID = "faba11c7-07d9-e711-80e1-005056ac45bb"

    FILTER = {
      "$filter" => "_dfe_contacttypeid_value eq #{TRAINEE_CONTACT_TYPE_DTTP_ID}",
    }.freeze

    QUERY = FILTER.to_query

  private

    def default_path
      @default_path ||= "/contacts?#{QUERY}"
    end

    def response
      @response ||= Client.get(request_uri, headers: { "Prefer" => "odata.maxpagesize=#{MAX_PAGE_SIZE}" })
    end
  end
end
