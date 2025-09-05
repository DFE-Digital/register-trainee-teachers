# frozen_string_literal: true

module PageObjects
  module Trainees
    class CourseEducationPhase < PageObjects::Base
      include PageObjects::Helpers

      set_url "/trainees/{id}/course-education-phase/edit"

      element :primary_phase, "#course-education-phase-form-course-education-phase-primary-field"
      element :secondary_phase, "#course-education-phase-form-course-education-phase-secondary-field"

      element :submit_button, "button[type='submit']"
    end
  end
end
