# frozen_string_literal: true

module PageObjects
  module Trainees
    class ConfirmOutcomeDetails < PageObjects::Base
      set_url "/trainees/{id}/outcome-details/confirm"
      element :continue, ".govuk-button"
    end
  end
end
