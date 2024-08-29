# frozen_string_literal: true

module Funding
  class UpdateTraineeSummaryRowRouteService
    include ServicePattern

    TRAINING_ROUTES = LeadPartnerTraineeSummariesImporter::TRAINING_ROUTES.merge(
      ProviderTraineeSummariesImporter::TRAINING_ROUTES,
    ).freeze

    def initialize(academic_year = nil)
      @academic_year = academic_year || current_academic_year
    end

    def call
      routes.each do |route|
        rows.where(route:).update_all(training_route: TRAINING_ROUTES[route.strip])
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
          training_route: nil,
        )
    end

    def current_academic_year
      "#{AcademicCycle.current.start_year}/#{AcademicCycle.current.end_year % 100}"
    end
  end
end
