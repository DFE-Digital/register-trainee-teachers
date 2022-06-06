# frozen_string_literal: true

module PageObjects
  module SystemAdmin
    module Funding
      class ProvidersPaymentSchedule < PageObjects::Base
        set_url "/system-admin/providers/{id}/funding/payment-schedule"

        class PaymentsTable < SitePrism::Section
          elements :rows, "tr"
        end

        sections :payment_breakdown_tables, PaymentsTable, ".app-table__in-accordion"

        element :view_trainee_summary, "a", text: "Trainee summary"
      end
    end
  end
end
