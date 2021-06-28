# frozen_string_literal: true

module PageObjects
  module Trainees
    class ConfirmWithdrawal < PageObjects::Base
      set_url "/trainees/{id}/withdraw/confirm"

      element :withdraw, "button[type='submit']"
      element :cancel, ".govuk-link.qa-cancel-link"
    end
  end
end
