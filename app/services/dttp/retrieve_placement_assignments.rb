# frozen_string_literal: true

module Dttp
  class RetrievePlacementAssignments
    include ServicePattern
    include SyncPattern

  private

    def default_path
      @default_path ||= "/dfe_placementassignments"
    end

    # TODO this is from Dttp::SyncPattern. 5000 max page size is too big for this but we need
    # to refactor Dttp::SyncPattern to all specifying the page size.
    def response
      @response ||= Client.get(request_uri, headers: { "Prefer" => "odata.maxpagesize=100" })
    end
  end
end
