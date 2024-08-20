# frozen_string_literal: true

module Funding
  class UpdateTraineeSummaryRowRouteService
    include ServicePattern

    ROUTE_MAPPING = {
      "Early years graduate employment based" => :early_years_salaried,
      "Provider-led" => :provider_led,
      "School Direct tuition fee" => :school_direct_tuition_fee,
      "School Direct salaried" => :school_direct_salaried,
      "Assessment only" => :assessment_only,
      "Early years assessment only" => :early_years_assessment_only,
      "Early years" => :early_years,
      "International qualified teacher status (iQTS)" => :iqts,
      "Primary and secondary" => :provider_led_undergrad,
      "Teaching apprenticeship" => :pg_teaching_apprenticeship,
      "School direct" => :school_direct_salaried,
      "HPITT" => :hpitt_postgrad,
      "Opt-in" => :opt_in_undergrad,
    }.freeze

    def initialize(academic_year: "2024/2025")
      @academic_year = academic_year
    end

    def call
      rows.find_each(batch_size: 100) do |row|
        row.update!(route_type: ROUTE_MAPPING[row.route])
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
