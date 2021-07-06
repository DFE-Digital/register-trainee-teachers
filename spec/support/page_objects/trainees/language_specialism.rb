# frozen_string_literal: true

module PageObjects
  module Trainees
    class LanguageSpecialism < PageObjects::Base
      include PageObjects::Helpers
      set_url "/trainees/{trainee_id}/language-specialisms/edit"

      element :submit_button, "button[type='submit']"
    end
  end
end
