# frozen_string_literal: true

module PageObjects
  module Trainees
    class EditUndoWithdrawal < PageObjects::Base
      include PageObjects::Helpers

      set_url "/trainees/{id}/undo-withdrawal/edit"

      element :comment, "#undo-withdrawal-form-comment-field"
      element :ticket, "#undo-withdrawal-form-ticket-field"

      element :continue, "button[type='submit']"
    end
  end
end
