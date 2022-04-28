# frozen_string_literal: true

module Funding
  module Parsers
    class LeadSchoolPaymentSchedules < PaymentSchedulesBase
      class << self
        def id_column
          "Lead school URN"
        end
      end
    end
  end
end
