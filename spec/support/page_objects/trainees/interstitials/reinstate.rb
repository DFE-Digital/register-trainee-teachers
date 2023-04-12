# frozen_string_literal: true

module PageObjects
  module Interstitials
    class Reinstate < PageObjects::Base
      set_url "/trainees/{id}/interstitial/reinstate"

      element :continue, ".govuk-button.continue"
    end
  end
end
