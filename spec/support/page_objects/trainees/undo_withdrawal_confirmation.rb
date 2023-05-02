# frozen_string_literal: true

module PageObjects
  module Trainees
    class UndoWithdrawalConfirmation < PageObjects::Base
      include PageObjects::Helpers

      set_url "/trainees/{id}/undo-withdrawal/confirmation"

      element :confirm, "button[type='submit']"
      element :cancel, "input[type='submit']"
    end
  end
end
