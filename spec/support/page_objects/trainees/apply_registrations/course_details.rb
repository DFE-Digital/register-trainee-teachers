# frozen_string_literal: true

module PageObjects
  module Trainees
    module ApplyRegistrations
      class CourseDetails < PageObjects::Base
        set_url "/trainees/{id}/apply-application/course-details/edit"

        element :confirm_course, "#apply-applications-review-course-form-reviewed-register-field"
        element :change_course, "#apply-applications-review-course-form-reviewed-change-field"

        element :continue, ".govuk-button.confirm-course"
      end
    end
  end
end
