# frozen_string_literal: true

module Dttp
  class RetrieveBursaryDetails
    include ServicePattern
    include SyncPattern

  private

    def default_path
      @default_path ||= "/dfe_bursarydetails"
    end
  end
end
