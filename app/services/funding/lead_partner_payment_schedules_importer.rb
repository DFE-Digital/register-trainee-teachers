# frozen_string_literal: true

module Funding
  class LeadPartnerPaymentSchedulesImporter < PayablePaymentSchedulesImporter
    def payable(id)
      School.find_by(urn: id)
    end
  end
end
