# frozen_string_literal: true

module PageObjects
  module Trainees
    module Funding
      class FundingEligibility < PageObjects::Base
        set_url "/trainees/{id}/funding/funding-eligibility/edit"

        element :eligible, "#funding-eligibility-form-funding-eligibility-eligible-field"
        element :not_eligible, "#funding-eligibility-form-funding-eligibility-not-eligible-field"

        element :submit_button, "button[type='submit']"
      end
    end
  end
end
