# frozen_string_literal: true

module Funding
  module Parsers
    class ProviderTraineeSummaries < PaymentSchedulesBase
      class << self
        def id_column
          "Provider"
        end

        def expected_headers
          [
            "Provider",
            "Provider name",
            "Academic Year",
            "Subject",
            "Route",
            "Lead School",
            "Lead School ID",
            "Cohort Level",
            "Bursary Amount",
            "Bursary Trainees",
            "Scholarship Amount",
            "Scholarship Trainees",
            "Tier 1 Amount",
            "Tier 1 Trainees",
            "Tier 2 Amount",
            "Tier 2 Trainees",
            "Tier 3 Amount",
            "Tier 3 Trainees",
          ]
        end
      end
    end
  end
end
