# frozen_string_literal: true

module PageObjects
  module Trainees
    module Funding
      class Bursary < PageObjects::Base
        set_url "/trainees/{id}/funding/bursary/edit"

        element :applying_for_bursary, "#funding-bursary-form-applying-for-bursary-true-field"
        element :not_applying_for_bursary, "#funding-bursary-form-applying-for-bursary-false-field"

        element :submit_button, "button[type='submit']"
      end
    end
  end
end
