# frozen_string_literal: true

module PageObjects
  module Trainees
    module Withdrawal
      class ConfirmDetail < PageObjects::Base
        include PageObjects::Helpers

        set_url "/trainees/{id}/withdrawal/confirm/edit"

        element :continue, "button[type='submit']"
      end
    end
  end
end
