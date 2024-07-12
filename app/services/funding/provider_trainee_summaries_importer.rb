# frozen_string_literal: true

module Funding
  class ProviderTraineeSummariesImporter < PayableTraineeSummariesImporter
    def payable(id)
      Provider.find_by(accreditation_id: id)
    end

    def academic_year_column
      "Academic Year"
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

    def amount_maps
      [
        { payment_type: "bursary", amount: "Bursary Amount", number_of_trainees: "Bursary Trainees", tier: nil },
        { payment_type: "scholarship", amount: "Scholarship Amount", number_of_trainees: "Scholarship Trainees", tier: nil },
        { payment_type: "bursary", amount: "Tier 1 Amount", number_of_trainees: "Tier 1 Trainees", tier: 1 },
        { payment_type: "bursary", amount: "Tier 2 Amount", number_of_trainees: "Tier 2 Trainees", tier: 2 },
        { payment_type: "bursary", amount: "Tier 3 Amount", number_of_trainees: "Tier 3 Trainees", tier: 3 },
      ]
    end
  end
end
