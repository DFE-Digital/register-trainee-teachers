# frozen_string_literal: true

module PageObjects
  module Trainees
    class EditStudyMode < PageObjects::Base
      include PageObjects::Helpers

      class StudyModeOptions < SitePrism::Section
        element :input, "input"
        element :label, "label"
      end

      set_url "/trainees/{trainee_id}/course-details/study-mode/edit"

      sections :options, StudyModeOptions, ".govuk-radios__item"

      element :continue, "button[type='submit']"
    end
  end
end
