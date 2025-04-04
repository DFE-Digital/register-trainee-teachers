# frozen_string_literal: true

module Funding
  module Parsers
    class LeadPartnerTraineeSummaries < Base
      class << self
        def id_column
          "Provider"
        end

        def expected_headers
          [
            "Academic year",
            "Provider",
            "Provider name",
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
