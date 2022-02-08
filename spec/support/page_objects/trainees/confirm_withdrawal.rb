# frozen_string_literal: true

module PageObjects
  module Trainees
    class ConfirmWithdrawal < PageObjects::Base
      set_url "/trainees/{id}/withdraw/confirm"

      element :start_date_change_link, "#trainee-start-date .govuk-link"
      element :withdraw, "button[type='submit']"
      element :cancel, ".govuk-link.qa-cancel-link"
    end
  end
end
