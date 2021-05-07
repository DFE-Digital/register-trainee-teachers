# frozen_string_literal: true

module PageObjects
  module Trainees
    class ConfirmPublishCourse < PageObjects::Base
      include PageObjects::Helpers
      set_url "/trainees/{trainee_id}/confirm-publish-course/{id}/edit"

      element :confirm_course_button, "input[name='commit'][value='Confirm course']"
      element :submit_button, "input[name='commit']"
    end
  end
end
