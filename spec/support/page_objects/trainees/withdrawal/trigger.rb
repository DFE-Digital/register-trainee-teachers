# frozen_string_literal: true

module PageObjects
  module Trainees
    module Withdrawal
      class Trigger < PageObjects::Base
        include PageObjects::Helpers

        set_url "/trainees/{id}/withdrawal/trigger/edit"

        element :continue, "button[type='submit']"
        element :cancel, "a", text: "Cancel and return to record"
      end
    end
  end
end
