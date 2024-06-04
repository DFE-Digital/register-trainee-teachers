# frozen_string_literal: true

module PageObjects
  module Trainees
    class Timeline < PageObjects::Base
      set_url "/trainees/{id}"

      element :tab_title, ".govuk-tabs__panel h2.govuk-heading-m"
    end
  end
end
