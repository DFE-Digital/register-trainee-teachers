# frozen_string_literal: true

module PageObjects
  module Trainees
    class ConfirmDeferral < PageObjects::Base
      set_url "/trainees/{id}/defer/confirm"

      element :defer, "input[name='commit']"
      element :cancel, ".govuk-link.qa-cancel-link"
    end
  end
end
