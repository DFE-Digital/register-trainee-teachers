# frozen_string_literal: true

module PageObjects
  module Trainees
    module Diversities
      class EthnicBackground < PageObjects::Base
        set_url "/trainees/{id}/diversity/ethnic-background/edit"
        element :bangladeshi, "#diversities-ethnic-background-form-ethnic-background-bangladeshi-field"
        element :not_provided, "#diversities-ethnic-background-form-ethnic-background-not-provided-field"
        element :submit_button, "input[name='commit']"
      end
    end
  end
end
