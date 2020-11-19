# frozen_string_literal: true

module PageObjects
  module Trainees
    class NotSupportedRoute < PageObjects::Base
      set_url "/trainees/not-supported-route"

      element :page_heading, ".govuk-heading-xl"
    end
  end
end
