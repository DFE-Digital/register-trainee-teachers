# frozen_string_literal: true

module Funding
  class LeadPartnerTraineeSummariesImporter < PayableTraineeSummariesImporter
    ROUTE_TYPES = {
      "School Direct salaried" => :school_direct_salaried,
      "post graduate teaching apprenticeship" => :pg_teaching_apprenticeship,
    }.freeze

    def payable(id)
      School.find_by(urn: id)
    end

    def academic_year_column
      "Academic year"
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

    def amount_maps
      [
        { payment_type: "grant", amount: "Funding/trainee", number_of_trainees: "Trainees", tier: nil },
      ]
    end
  end
end
