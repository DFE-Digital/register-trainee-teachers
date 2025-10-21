# frozen_string_literal: true

module PageObjects
  module Trainees
    module Withdrawal
      class Start < PageObjects::Base
        include PageObjects::Helpers

        set_url "/trainees/{id}/withdrawal/start"

        element :continue, ".govuk-button", text: "Start"
        element :cancel, "a", text: "Cancel and return to record"
      end
    end
  end
end
