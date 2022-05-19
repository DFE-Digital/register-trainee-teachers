# frozen_string_literal: true

module Funding
  module Parsers
    class ProviderPaymentSchedules < Base
      class << self
        def id_column
          "Provider ID"
        end

        def expected_headers
          [
            "Academic year",
            "Provider ID",
            "Provider name",
            "Description",
            "Total funding",
            "August",
            "September",
            "October",
            "November",
            "December",
            "January",
            "February",
            "March",
            "April",
            "May",
            "June",
            "July",
          ]
        end
      end
    end
  end
end
