module PageObjects
  module Trainees
    class ConfirmDiversityDetails < PageObjects::Trainees::ConfirmDetails
      set_url "/trainees/{id}/diversity/{section}/confirm"
    end
  end
end
