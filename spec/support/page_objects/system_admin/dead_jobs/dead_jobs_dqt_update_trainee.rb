# frozen_string_literal: true

module PageObjects
  module SystemAdmin
    module DeadJobs
      class DqtUpdateTrainee < PageObjects::Base
        set_url "/system-admin/dead_jobs/DeadJobs::DqtUpdateTrainee"

        element :view_trainee_button, "button", text: "View"
        element :retry_trainee_button, "button", text: "Retry"
        element :delete_trainee_button, "button", text: "Delete"
      end
    end
  end
end
