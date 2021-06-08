# frozen_string_literal: true

module Dttp
  class RetrieveProviders
    include ServicePattern
    include SyncPattern

    INSTITUTION_TYPES = CodeSets::InstitutionTypes::MAPPING.values.flat_map { |institution| "_dfe_institutiontypeid_value eq #{institution[:entity_id]}" }.join(" or ")

    ACTIVE_STATECODE = 0
    CLOSED_STATUSCODE = 300_000_002

    FILTER = {
      "$filter" => "dfe_provider eq true and (statecode eq #{ACTIVE_STATECODE} and statuscode ne #{CLOSED_STATUSCODE}) and (#{INSTITUTION_TYPES})",
    }.freeze

    SELECT = {
      "$select" => %w[
        name
        dfe_ukprn
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
