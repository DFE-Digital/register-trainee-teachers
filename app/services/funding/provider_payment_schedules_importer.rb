# frozen_string_literal: true

module Funding
  class ProviderPaymentSchedulesImporter < PayablePaymentSchedulesImporter
    def payable(id)
      Provider.find_by(accreditation_id: id)
    end
  end
end
