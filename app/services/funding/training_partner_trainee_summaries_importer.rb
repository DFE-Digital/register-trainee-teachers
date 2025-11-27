# frozen_string_literal: true

module Funding
  class TrainingPartnerTraineeSummariesImporter < PayableTraineeSummariesImporter
    class SummaryRowMapper < PayableTraineeSummariesImporter::SummaryRowMapper
      TRAINING_ROUTES = {
        "School Direct salaried" => TRAINING_ROUTE_ENUMS[:school_direct_salaried],
        "Post graduate teaching apprenticeship" => TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship],
      }.freeze

    private

      def training_route
        TRAINING_ROUTES[route]
      end

      def route_column
        "Description"
      end

      def lead_school_name_column
        "Lead school name"
      end

      def lead_school_urn_column
        "Lead school URN"
      end
    end

  private

    def academic_year_column
      "Academic year"
    end

    def payable(id)
      Provider.find_by(accreditation_id: id)
    end

    def amount_maps
      [
        { payment_type: "grant", amount: "Funding/trainee", number_of_trainees: "Trainees", tier: nil },
      ]
    end
  end
end
