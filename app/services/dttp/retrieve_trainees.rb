# frozen_string_literal: true

module Dttp
  class RetrieveTrainees
    include ServicePattern
    include SyncPattern

    FILTER = {
      "$filter" => "_dfe_contacttypeid_value eq faba11c7-07d9-e711-80e1-005056ac45bb",
    }.freeze

    QUERY = FILTER.to_query

  private

    def default_path
      @default_path ||= "/contacts?#{QUERY}"
    end

    # TODO this is from Dttp::SyncPattern. 5000 max page size is too big for this but we need
    # to refactor Dttp::SyncPattern to all specifying the page size.
    def response
      @response ||= Client.get(request_uri, headers: { "Prefer" => "odata.maxpagesize=50" })
    end
  end
end
