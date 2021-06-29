# frozen_string_literal: true

module PageObjects
  module Trainees
    class ConfirmFunding < PageObjects::Base
      set_url "/trainees/{id}/funding/confirm"

      element :continue, "button[type='submit']"
    end
  end
end
