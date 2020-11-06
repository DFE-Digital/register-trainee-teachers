module PageObjects
  module Trainees
    class ConfirmDetails < PageObjects::Base
      set_url "/trainees/{id}/{section}/confirm"
      element :submit_button, "input[name='commit']"
    end
  end
end
