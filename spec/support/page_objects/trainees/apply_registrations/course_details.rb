# frozen_string_literal: true

module PageObjects
  module Trainees
    module ApplyRegistrations
      class CourseDetails < PageObjects::Base
        class CourseOptions < SitePrism::Section
          element :input, "input"
          element :label, "label"
        end

        set_url "/trainees/{id}/apply-application/course-details/edit"

        sections :course_options, CourseOptions, ".govuk-radios__item"

        element :continue, "button[type='submit']"
      end
    end
  end
end
