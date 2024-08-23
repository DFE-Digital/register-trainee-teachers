# frozen_string_literal: true

module Funding
  class UpdateTraineeSummaryRowRouteService
    include ServicePattern

    ROUTE_TYPES = LeadPartnerTraineeSummariesImporter::ROUTE_TYPES.merge(
      ProviderTraineeSummariesImporter::ROUTE_TYPES,
    ).freeze

    def initialize(academic_year = nil)
      @academic_year = academic_year || current_academic_year
    end

    def call
      routes.each do |route|
        rows.where(route:).update_all(route_type: ROUTE_TYPES[route.strip])
      end
    end

  private

    attr_reader :academic_year

    def routes
      rows.distinct.pluck(:route)
    end

    def rows
      TraineeSummaryRow
        .joins(:trainee_summary)
        .where(
          trainee_summary: { academic_year: },
          route_type: nil,
        )
    end

    def current_academic_year
      "#{AcademicCycle.current.start_year}/#{AcademicCycle.current.end_year % 100}"
    end
  end
end
