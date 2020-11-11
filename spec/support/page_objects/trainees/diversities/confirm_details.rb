module PageObjects
  module Trainees
    module Diversities
      class ConfirmDetails < PageObjects::Trainees::ConfirmDetails
        set_url "/trainees/{id}/diversity/{section}/confirm"
      end
    end
  end
end
