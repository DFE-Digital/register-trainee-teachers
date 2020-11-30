# frozen_string_literal: true

module PageObjects
  module Trainees
    class Index < PageObjects::Base
      set_url "/trainees"

      element :page_heading, ".govuk-heading-xl"

      element :add_trainee_link, "a", text: "Add a trainee"

      elements :trainee_data, ".app-application-card"

      elements :trainee_name, ".app-application-card .govuk-link"
    end
  end
end
