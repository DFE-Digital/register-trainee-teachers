# frozen_string_literal: true

module PageObjects
  module Trainees
    class SubjectSpecialism < PageObjects::Base
      include PageObjects::Helpers
      set_url "/trainees/{trainee_id}/subject-specialism/{position}/edit"

      element :submit_button, "button[type='submit']"
    end
  end
end
