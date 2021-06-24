# frozen_string_literal: true

module PageObjects
  module Trainees
    module Diversities
      class EthnicGroup < PageObjects::Base
        set_url "/trainees/{id}/diversity/ethnic-group/edit"
        element :asian, "#diversities-ethnic-group-form-ethnic-group-asian-ethnic-group-field"
        element :black, "#diversities-ethnic-group-form-ethnic-group-black-ethnic-group-field"
        element :mixed, "#diversities-ethnic-group-form-ethnic-group-mixed-ethnic-group-field"
        element :white, "#diversities-ethnic-group-form-ethnic-group-white-ethnic-group-field"
        element :other, "#diversities-ethnic-group-form-ethnic-group-other-ethnic-group-field"
        element :not_provided, "#diversities-ethnic-group-form-ethnic-group-not-provided-ethnic-group-field"
        element :submit_button, "button[type='submit']"
      end
    end
  end
end
