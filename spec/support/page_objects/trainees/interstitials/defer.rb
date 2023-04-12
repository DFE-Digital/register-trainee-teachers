# frozen_string_literal: true

module PageObjects
  module Interstitials
    class Defer < PageObjects::Base
      set_url "/trainees/{id}/interstitial/defer"

      element :continue, ".govuk-button.continue"
    end
  end
end
