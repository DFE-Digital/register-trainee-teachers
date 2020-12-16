# frozen_string_literal: true

module PageObjects
  module Trainees
    module Diversities
      class Disclosure < PageObjects::Base
        set_url "/trainees/{id}/diversity/information-disclosed/edit"
        element :yes, "#diversities-disclosure-form-diversity-disclosure-diversity-disclosed-field"
        element :no, "#diversities-disclosure-form-diversity-disclosure-diversity-not-disclosed-field"
        element :submit_button, "input[name='commit']"
      end
    end
  end
end
