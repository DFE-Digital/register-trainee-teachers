# frozen_string_literal: true

module PageObjects
  module Trainees
    class ShowUndoWithdrawal < PageObjects::Base
      include PageObjects::Helpers

      set_url "/trainees/{id}/undo-withdrawal"

      element :continue, "a", text: "Continue"
    end
  end
end
