# frozen_string_literal: true

module PageObjects
  module Trainees
    class PublishCourseDetails < PageObjects::Base
      include PageObjects::Helpers

      class CourseOptions < SitePrism::Section
        element :input, "input"
        element :label, "label"
      end

      set_url "/trainees/{id}/publish-course-details/edit"

      sections :course_options, CourseOptions, ".govuk-radios__item"

      element :submit_button, "button[type='submit']"

      element :route_message, "#publish-course-details-form-course-uuid-hint"
    end
  end
end
