# frozen_string_literal: true

module Funding
  class UpdateTraineeSummaryRowRouteService
    include ServicePattern

    class TrainingRouteMapper
      TRAINING_ROUTES = TrainingPartnerTraineeSummariesImporter::SummaryRowMapper::TRAINING_ROUTES.merge(
        ProviderTraineeSummariesImporter::SummaryRowMapper::TRAINING_ROUTES,
      ).freeze

      def initialize(route, cohort_level)
        @route        = route.strip
        @cohort_level = cohort_level.to_s.strip
      end

      def to_h
        {
          training_route:,
        }
      end

    private

      attr_reader :route, :cohort_level

      def training_route
        TRAINING_ROUTES.fetch(route, {})[cohort_level].presence || TRAINING_ROUTES[route]
      end
    end

    def initialize(academic_year = nil)
      @academic_year = academic_year || current_academic_year
    end

    def call
      routes_and_cohort_levels.each do |route, cohort_level|
        rows.where(route:, cohort_level:).update_all(
          TrainingRouteMapper.new(route, cohort_level).to_h,
        )
      end
    end

  private

    attr_reader :academic_year

    def routes_and_cohort_levels
      rows.distinct.pluck(:route, :cohort_level)
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
