# frozen_string_literal: true

module Funding
  module Parsers
    class TrainingPartnerPaymentSchedules < Base
      class << self
        def id_column
          "Lead school URN"
        end

        def expected_headers
          [
            "Academic year",
            "Lead school URN",
            "Lead school name",
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
