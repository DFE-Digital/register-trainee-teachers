# frozen_string_literal: true

module PageObjects
  module Trainees
    module Withdrawal
      class Reason < PageObjects::Base
        include PageObjects::Helpers

        set_url "/trainees/{id}/withdrawal/reason/edit"

        element :continue, "button[type='submit']"
      end
    end
  end
end
