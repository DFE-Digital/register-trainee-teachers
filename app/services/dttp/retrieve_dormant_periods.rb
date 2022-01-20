# frozen_string_literal: true

module Dttp
  class RetrieveDormantPeriods
    include ServicePattern
    include SyncPattern

    MAX_PAGE_SIZE = 100

  private

    def default_path
      @default_path ||= "/dfe_dormantperiods"
    end

    def response
      @response ||= Client.get(request_uri, headers: { "Prefer" => "odata.maxpagesize=#{MAX_PAGE_SIZE}" })
    end
  end
end
