# frozen_string_literal: true

module PageObjects
  module SystemAdmin
    module DeadJobs
      class DeadBackgroundJobs < PageObjects::Base
        set_url "/system-admin/dead_jobs"

        element :trs_update_trainee_dead_jobs_view_button, "a", id: "view_TrsUpdateTrainee", text: "View"
      end
    end
  end
end
