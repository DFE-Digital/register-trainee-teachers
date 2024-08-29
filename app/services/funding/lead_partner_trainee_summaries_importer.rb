# frozen_string_literal: true

module Funding
  class LeadPartnerTraineeSummariesImporter < PayableTraineeSummariesImporter
    class SummaryRowMapper < PayableTraineeSummariesImporter::SummaryRowMapper
      TRAINING_ROUTES = {
        "School Direct salaried" => :school_direct_salaried,
        "Post graduate teaching apprenticeship" => :pg_teaching_apprenticeship,
      }.freeze

    private

      def training_route
        self.class::TRAINING_ROUTES[route]
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

    def payable(id)
      School.find_by(urn: id)
    end

    def amount_maps
      [
        { payment_type: "grant", amount: "Funding/trainee", number_of_trainees: "Trainees", tier: nil },
      ]
    end

    def academic_year_column
      "Academic year"
    end
  end
end
