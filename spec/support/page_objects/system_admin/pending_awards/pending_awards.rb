# frozen_string_literal: true

module PageObjects
  module SystemAdmin
    module PendingAwards
      class PendingAwardsSummary < PageObjects::Base
        set_url "/system-admin/pending_awards"

        class SortBy < SitePrism::Section
          element :days_waiting, "a", text: "Days waiting"
          element :trn, "a", text: "TRN"
          element :register_id, "a", text: "Register"
        end

        class Table < SitePrism::Section
          elements :rows, "tr"
        end

        sections :table, Table, ".govuk-table__body"
        section :sort_by, SortBy, ".sort-by-items"
      end
    end
  end
end
