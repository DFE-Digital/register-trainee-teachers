# frozen_string_literal: true

module PageObjects
  module SystemAdmin
    module DeadJobs
      class DqtUpdateTrainee < PageObjects::Base
        set_url "/system-admin/dead_jobs/DeadJobs::DqtUpdateTrainee"

        element :view_trainee_button, "a", id: "view_10001", text: "View"
      end
    end
  end
end
