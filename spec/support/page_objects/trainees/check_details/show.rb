module PageObjects
  module Trainees
    module CheckDetails
      class Show < PageObjects::Base
        set_url "/trainees/{id}/check-details"
        element :submit_button, "input[name='commit']"
      end
    end
  end
end
