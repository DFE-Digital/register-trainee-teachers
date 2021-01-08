# frozen_string_literal: true

module PageObjects
  module Trainees
    module Diversities
      class DisabilityDisclosure < PageObjects::Base
        set_url "/trainees/{id}/diversity/disability-disclosure/edit"
        element :disabled, "#diversities-disability-disclosure-form-disability-disclosure-disabled-field"
        element :no_disability, "#diversities-disability-disclosure-form-disability-disclosure-no-disability-field"
        element :disability_not_provided, "#diversities-disability-disclosure-form-disability-disclosure-disability-not-provided-field"
        element :submit_button, "input[name='commit']"
      end
    end
  end
end
