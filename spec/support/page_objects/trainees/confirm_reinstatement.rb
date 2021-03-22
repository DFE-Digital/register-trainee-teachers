# frozen_string_literal: true

module PageObjects
  module Trainees
    class ConfirmReinstatement < PageObjects::Base
      set_url "/trainees/{id}/reinstate/confirm"

      element :reinstate, "input[name='commit']"
      element :cancel, ".govuk-link.qa-cancel-link"
    end
  end
end
