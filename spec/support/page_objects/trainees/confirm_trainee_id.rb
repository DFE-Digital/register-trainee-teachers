# frozen_string_literal: true

module PageObjects
  module Trainees
    class ConfirmTraineeId < PageObjects::Base
      set_url "/trainees/{id}/trainee-id/confirm"
      element :confirm, "button[type='submit']"
    end
  end
end
