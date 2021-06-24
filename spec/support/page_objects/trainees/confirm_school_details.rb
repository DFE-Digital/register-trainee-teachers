# frozen_string_literal: true

module PageObjects
  module Trainees
    class ConfirmSchoolDetails < PageObjects::Base
      set_url "/trainees/{id}/schools/confirm"

      element :continue, "button[type='submit']"
    end
  end
end
