# frozen_string_literal: true

module PageObjects
  module Trainees
    class ConfirmDeferral < PageObjects::Base
      set_url "/trainees/{id}/defer/confirm"

      element :start_date_change_link, "#trainee-start-date .govuk-link"
      element :defer_reason_change_link, "#reason-for-deferral .govuk-link"
      element :defer, "button[type='submit']"
      element :cancel, ".govuk-link.qa-cancel-link"
    end
  end
end
