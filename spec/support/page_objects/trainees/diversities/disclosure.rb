module PageObjects
  module Trainees
    module Diversities
      class Disclosure < PageObjects::Base
        set_url "/trainees/{id}/diversity/information-disclosed/edit"
        element :yes, "#diversities-disclosure-diversity-disclosure-yes-field"
        element :no, "#diversities-disclosure-diversity-disclosure-no-field"
        element :submit_button, "input[name='commit']"
      end
    end
  end
end
