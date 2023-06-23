# frozen_string_literal: true

module PageObjects
  module Trainees
    module Withdrawal
      class ExtraInformation < PageObjects::Base
        include PageObjects::Helpers

        set_url "/trainees/{id}/withdrawal/extra-information/edit"

        element :withdraw_reasons_details, "#withdrawal-extra-information-form-withdraw-reasons-details-field"
        element :withdraw_reasons_dfe_details, "#withdrawal-extra-information-form-withdraw-reasons-dfe-details-field"

        element :continue, "button[type='submit']"
        element :cancel, "a", text: "Cancel and return to record"
      end
    end
  end
end
