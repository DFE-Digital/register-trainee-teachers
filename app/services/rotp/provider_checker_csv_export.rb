# frozen_string_literal: true

require "csv"

module Rotp
  class ProviderCheckerCsvExport
    include ServicePattern

    HEADERS = %w[comparison_group status operating_name code urn accreditation_status provider_type].freeze

    def initialize(checker)
      @checker = checker
    end

    def call
      CSV.generate(force_quotes: true) do |csv|
        csv << HEADERS
        append_rows(csv, "accredited", "matched", checker.accredited_matched)
        append_rows(csv, "accredited", "missing_from_register", checker.accredited_missing_from_register)
        append_rows(csv, "accredited", "missing_from_rotp", checker.accredited_missing_from_rotp)
        append_rows(csv, "training_partner", "matched", checker.training_partner_matched + checker.school_matched)
        append_rows(csv, "training_partner", "missing_from_register", checker.training_partner_missing_from_register + checker.school_missing_from_register)
        append_rows(csv, "training_partner", "missing_from_rotp", checker.training_partner_missing_from_rotp + checker.school_missing_from_rotp)
      end
    end

  private

    attr_reader :checker

    # Prefix with a formula to prevent Excel/Sheets coercing numeric-looking values (e.g. codes, URNs) to numbers.
    def spreadsheet_text(value)
      value.present? ? "=\"#{value}\"" : value
    end

    def append_rows(csv, comparison_group, status, rows)
      rows.each do |row|
        csv << [
          comparison_group,
          status,
          row["operating_name"] || row["name"],
          spreadsheet_text(row["code"]),
          spreadsheet_text(row["urn"]),
          row["accreditation_status"],
          row["provider_type"],
        ]
      end
    end
  end
end
