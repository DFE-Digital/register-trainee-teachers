# frozen_string_literal: true

module PageObjects
  module Trainees
    class LanguageSpecialismOptions < SitePrism::Section
      element :input, "input"
      element :label, "label"
    end

    class LanguageSpecialism < PageObjects::Base
      include PageObjects::Helpers
      set_url "/trainees/{trainee_id}/language-specialisms/edit"

      sections :language_specialism_options, LanguageSpecialismOptions, ".govuk-checkboxes__item"

      element :submit_button, "button[type='submit']"
    end
  end
end
