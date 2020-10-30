module PageObjects
  module Trainees
    module Diversities
      class EthnicGroup < PageObjects::Base
        set_url "/trainees/{id}/diversity/ethnic-group/edit"
        element :asian, "#diversities-ethnic-group-ethnic-group-asian-ethnic-group-field"
        element :black, "#diversities-ethnic-group-ethnic-group-black-ethnic-group-field"
        element :mixed, "#diversities-ethnic-group-ethnic-group-mixed-ethnic-group-field"
        element :white, "#diversities-ethnic-group-ethnic-group-white-ethnic-group-field"
        element :another, "#diversities-ethnic-group-ethnic-group-other-ethnic-group-field"
        element :not_provided, "#diversities-ethnic-group-ethnic-group-no-ethnic-group-provided-field"
        element :submit_button, "input[name='commit']"
      end
    end
  end
end
