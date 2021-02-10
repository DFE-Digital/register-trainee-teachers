# frozen_string_literal: true

module PageObjects
  module Trainees
    class ConfirmTrainingDetails < PageObjects::Base
      set_url "/trainees/{id}/training-details/confirm"

      element :confirm, ".govuk-button"
    end
  end
end
