# frozen_string_literal: true

module PageObjects
  module Trainees
    module Withdrawal
      class ConfirmDetail < PageObjects::Base
        include PageObjects::Helpers

        set_url "/trainees/{id}/withdrawal/confirm/edit"

        element :continue, "button[type='submit']"
        element :cancel, "a", text: "Cancel and return to record"
        element :start_date_change_link, ".trainee-start-date a.govuk-link"
      end
    end
  end
end
