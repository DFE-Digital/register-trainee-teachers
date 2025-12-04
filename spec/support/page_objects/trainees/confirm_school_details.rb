# frozen_string_literal: true

module PageObjects
  module Trainees
    class ConfirmSchoolDetails < PageObjects::Base
      set_url "/trainees/{id}/schools/confirm"

      element :continue, "button[type='submit']"
      element :employing_school_row, ".employing-school"
      element :training_partner_row, ".training-partner"
    end
  end
end
