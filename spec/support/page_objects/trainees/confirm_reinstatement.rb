# frozen_string_literal: true

module PageObjects
  module Trainees
    class ConfirmReinstatement < PageObjects::Base
      set_url "/trainees/{id}/reinstate/confirm"
      element :confirm, "input[name='commit']"
    end
  end
end
