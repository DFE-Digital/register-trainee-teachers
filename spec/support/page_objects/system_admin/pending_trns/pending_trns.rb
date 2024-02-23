# frozen_string_literal: true

module PageObjects
  module SystemAdmin
    module PendingTrns
      class PendingTrnsSummary < PageObjects::Base
        set_url "/system-admin/pending_trns"

        element :check_for_trn_button, "button", text: "Check for TRN"
        element :resumbit_for_trn_button, "button", text: "Re-submit for TRN"

        class SortBy < SitePrism::Section
          element :days_waiting, "a", text: "Days waiting"
          element :register_id, "a", text: "Register"
        end

        class Accordian < SitePrism::Section
          elements :items, ".govuk-accordion__section"
        end

        section :accordian, Accordian, ".govuk-accordion"
        section :sort_by, SortBy, ".sort-by-items"
      end
    end
  end
end
