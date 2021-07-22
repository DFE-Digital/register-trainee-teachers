# frozen_string_literal: true

module PageObjects
  module Trainees
    module ApplyRegistrations
      class CourseDetails < PageObjects::Base
        set_url "/trainees/{id}/apply-application/course-details"

        element :select_specialisms_button, ".govuk-button.select-specialisms"
      end
    end
  end
end
