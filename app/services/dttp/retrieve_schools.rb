# frozen_string_literal: true

module Dttp
  class RetrieveSchools
    include ServicePattern
    include SyncPattern

    FILTER = {
      "$filter" => "dfe_provider eq false",
    }.freeze

    SELECT = {
      "$select" => %w[
        name
        dfe_urn
        accountid
      ].join(","),
    }.freeze

    QUERY = FILTER.merge(SELECT).to_query

  private

    def default_path
      @default_path ||= "/accounts?#{QUERY}"
    end
  end
end
