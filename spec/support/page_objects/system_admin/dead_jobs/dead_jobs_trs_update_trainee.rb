# frozen_string_literal: true

module PageObjects
  module SystemAdmin
    module DeadJobs
      class TrsUpdateTrainee < PageObjects::Base
        set_url "/system-admin/dead_jobs/DeadJobs::TrsUpdateTrainee"

        element :view_trainee_button, "button", text: "View"
        element :retry_trainee_button, "button", text: "Retry"
        element :delete_trainee_button, "button", text: "Delete"

        class SortBy < SitePrism::Section
          element :days_waiting, "a", text: "Days waiting"
          element :trn, "a", text: "TRN"
          element :register_id, "a", text: "Register"
        end

        class DeadJobsTable < SitePrism::Section
          elements :rows, "tr"
        end

        sections :dead_jobs_table, DeadJobsTable, ".govuk-table__body"
        section :sort_by, SortBy, ".sort-by-items"
      end
    end
  end
end
