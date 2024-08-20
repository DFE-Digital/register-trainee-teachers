# frozen_string_literal: true

module Funding
  class UpdateTraineeSummaryRowRouteService
    include ServicePattern

    ROUTE_TYPES = LeadPartnerTraineeSummariesImporter::ROUTE_TYPES.merge(
      ProviderTraineeSummariesImporter::ROUTE_TYPES,
    ).freeze

    def initialize(academic_year: "2024/2025")
      @academic_year = academic_year
    end

    def call
      rows.find_each(batch_size: 100) do |row|
        row.update!(route_type: ROUTE_TYPES[row.route])
      end
    end

  private

    attr_reader :academic_year

    def rows
      @rows ||= TraineeSummaryRow
        .joins(:trainee_summary)
        .where(
          trainee_summary: { academic_year: },
          route_type: nil,
        )
    end
  end
end
