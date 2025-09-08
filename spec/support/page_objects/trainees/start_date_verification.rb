# frozen_string_literal: true

module PageObjects
  module Trainees
    class StartDateVerification < PageObjects::Base
      include PageObjects::Helpers

      set_url "/trainees/{id}/start-date-verification"

      element :started_option, "#start-date-verification-form-trainee-has-started-course-yes-field"
      element :not_started_option, "#start-date-verification-form-trainee-has-started-course-no-field"

      element :continue, "button[type='submit']"
    end
  end
end
