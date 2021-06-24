# frozen_string_literal: true

module PageObjects
  module Trainees
    class ConfirmPublishCourse < PageObjects::Base
      include PageObjects::Helpers
      set_url "/trainees/{trainee_id}/confirm-publish-course/{id}/edit"

      element :confirm_course_button, "button[type='submit']", text: "Confirm course"
      element :submit_button, "button[type='submit']"
    end
  end
end
