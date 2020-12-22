# frozen_string_literal: true

module PageObjects
  module Trainees
    class ConfirmDeferral < PageObjects::Base
      set_url "/trainees/{id}/defer/confirm"
      element :continue, ".govuk-button"
    end
  end
end
