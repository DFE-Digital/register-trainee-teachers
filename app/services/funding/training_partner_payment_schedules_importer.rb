# frozen_string_literal: true

module Funding
  class TrainingPartnerPaymentSchedulesImporter < PayablePaymentSchedulesImporter
    def payable(id)
      School.find_by(urn: id)
    end
  end
end
