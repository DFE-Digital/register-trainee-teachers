# frozen_string_literal: true

module PageObjects
  module Trainees
    class ConfirmWithdrawal < PageObjects::Base
      set_url "/trainees/{id}/withdraw/confirm"
      element :confirm, ".govuk-button"
    end
  end
end
