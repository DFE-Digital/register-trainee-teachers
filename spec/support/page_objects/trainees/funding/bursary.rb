# frozen_string_literal: true

module PageObjects
  module Trainees
    module Funding
      class Bursary < PageObjects::Base
        set_url "/trainees/{id}/funding/bursary/edit"

        element :applying_for_bursary, "#funding-bursary-form-funding-type-bursary-field"
        element :applying_for_scholarship, "#funding-bursary-form-funding-type-scholarship-field"
        element :bursary_tier, "#funding-bursary-form-funding-type-tier-one-field"
        element :not_applying_for_bursary, "#funding-bursary-form-funding-type-none-field"

        element :submit_button, "button[type='submit']"
      end
    end
  end
end
