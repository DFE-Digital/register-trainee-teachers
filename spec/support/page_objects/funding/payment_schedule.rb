# frozen_string_literal: true

module PageObjects
  module Funding
    class PaymentSchedule < PageObjects::Base
      set_url "funding/payment-schedule"

      class PaymentsTable < SitePrism::Section
        elements :rows, "tr"
      end

      section :payments_table, PaymentsTable, "#payments"
      section :predicted_payments_table, PaymentsTable, "#predicted-payments"
      sections :payment_breakdown_tables, PaymentsTable, ".app-table__in-accordion"
      element :export_link, ".app-trainee-export"
    end
  end
end
