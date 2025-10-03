# frozen_string_literal: true

module Funding
  class ProviderTraineeSummariesImporter < PayableTraineeSummariesImporter
    class SummaryRowMapper < PayableTraineeSummariesImporter::SummaryRowMapper
      TRAINING_ROUTES = {
        "EYITT Graduate entry" => TRAINING_ROUTE_ENUMS[:early_years_postgrad],
        "EYITT Graduate employment-based" => TRAINING_ROUTE_ENUMS[:early_years_salaried],
        "Provider-led" => {
          "PG" => TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
          "UG" => TRAINING_ROUTE_ENUMS[:provider_led_undergrad],
        },
        "Undergraduate opt-in" => TRAINING_ROUTE_ENUMS[:opt_in_undergrad],
        "School Direct tuition fee" => TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee],
        "Teacher Degree Apprenticeship" => TRAINING_ROUTE_ENUMS[:teacher_degree_apprenticeship],
      }.freeze

      def to_h
        super.merge(
          cohort_level:,
        )
      end

    private

      def training_route
        TRAINING_ROUTES.fetch(route, {})[cohort_level] || TRAINING_ROUTES[route]
      end

      def cohort_level
        row_hash[cohort_level_column].strip
      end

      def route_column
        "Route"
      end

      def lead_school_name_column
        "Lead School"
      end

      def lead_school_urn_column
        "Lead School ID"
      end

      def cohort_level_column
        "Cohort Level"
      end
    end

  private

    def payable(id)
      Provider.find_by(accreditation_id: id)
    end

    def amount_maps
      [
        { payment_type: "bursary", amount: "Bursary Amount", number_of_trainees: "Bursary Trainees", tier: nil },
        { payment_type: "scholarship", amount: "Scholarship Amount", number_of_trainees: "Scholarship Trainees", tier: nil },
        { payment_type: "bursary", amount: "Tier 1 Amount", number_of_trainees: "Tier 1 Trainees", tier: 1 },
        { payment_type: "bursary", amount: "Tier 2 Amount", number_of_trainees: "Tier 2 Trainees", tier: 2 },
        { payment_type: "bursary", amount: "Tier 3 Amount", number_of_trainees: "Tier 3 Trainees", tier: 3 },
      ]
    end

    def academic_year_column
      "Academic Year"
    end
  end
end
