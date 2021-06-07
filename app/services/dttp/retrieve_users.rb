# frozen_string_literal: true

module Dttp
  class RetrieveUsers
    include ServicePattern
    include SyncPattern

    SELECT = {
      "$select" => %w[
        firstname
        lastname
        emailaddress1
        contactid
        _parentcustomerid_value
      ].join(","),
    }.freeze

    ACTIVE_STATECODE = 0

    FILTER = {
      "$filter" => "dfe_portaluser eq true and statecode eq #{ACTIVE_STATECODE}",
    }.freeze

    QUERY = FILTER.merge(SELECT).to_query

  private

    def default_path
      @default_path ||= "/contacts?#{QUERY}"
    end
  end
end
