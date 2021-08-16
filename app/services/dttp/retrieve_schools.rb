# frozen_string_literal: true

module Dttp
  class RetrieveSchools
    include ServicePattern
    include SyncPattern

    SELECT = {
      "$select" => %w[
        name
        dfe_urn
        accountid
        statuscode
      ].join(","),
    }.freeze

  private

    def default_path
      @default_path ||= "/accounts?#{SELECT.to_query}"
    end
  end
end
