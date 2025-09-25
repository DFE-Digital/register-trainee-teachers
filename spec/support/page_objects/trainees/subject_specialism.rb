# frozen_string_literal: true

module PageObjects
  module Trainees
    class SpecialismOptions < SitePrism::Section
      element :input, "input"
      element :label, "label"
    end

    class SubjectSpecialism < PageObjects::Base
      include PageObjects::Helpers

      set_url "/trainees/{trainee_id}/subject-specialism/{position}/edit"

      sections :specialism_options, SpecialismOptions, ".govuk-radios__item"

      element :submit_button, "button[type='submit']"
    end
  end
end
