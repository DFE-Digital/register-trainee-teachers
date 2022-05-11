# frozen_string_literal: true

module Funding
  module Parsers
    class LeadSchoolTraineeSummaries < PaymentSchedulesBase
      class << self
        def id_column
          "Lead school URN"
        end

        def expected_headers
          [
            "Academic year",
            "Lead school URN",
            "Lead school name",
            "Subject",
            "Description",
            "Funding/trainee",
            "Trainees",
            "Total Funding",
          ]
        end
      end
    end
  end
end
