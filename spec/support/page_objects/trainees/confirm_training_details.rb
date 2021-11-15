# frozen_string_literal: true

module PageObjects
  module Trainees
    class ConfirmTrainingDetails < PageObjects::Base
      set_url "/trainees/{id}/training-details/confirm"

      element :confirm, "button[type='submit']"
    end
  end
end
