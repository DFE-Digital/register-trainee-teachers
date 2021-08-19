# frozen_string_literal: true

module PageObjects
  module Trainees
    class EditStudyMode < PageObjects::Base
      include PageObjects::Helpers
      set_url "/trainees/{trainee_id}/course-details/study-mode/edit"
    end
  end
end
