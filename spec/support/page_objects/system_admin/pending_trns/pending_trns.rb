# frozen_string_literal: true

module PageObjects
  module SystemAdmin
    module PendingTrns
      class PendingTrnsSummary < PageObjects::Base
        set_url "/system-admin/pending_trns"

        element :check_for_trn_button, "button", text: "Check for TRN"
        element :resumbit_for_trn_button, "button", text: "Re-request for TRN"
      end
    end
  end
end
