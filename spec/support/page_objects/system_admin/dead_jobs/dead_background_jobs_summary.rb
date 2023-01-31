# frozen_string_literal: true

module PageObjects
  module SystemAdmin
    module DeadJobs
      class DeadBackgroundJobs < PageObjects::Base
        set_url "/system-admin/dead_jobs"

        element :dqt_update_trainee_dead_jobs_view_button, "a", id: "view_DqtUpdateTrainee", text: "View"
      end
    end
  end
end
