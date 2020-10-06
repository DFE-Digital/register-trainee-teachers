module PageObjects
  module Trainees
    class NotSupportedRoute < PageObjects::Base
      set_url "/trainees/not-supported-route"

      element :page_title, ".govuk-heading-xl"
    end
  end
end
