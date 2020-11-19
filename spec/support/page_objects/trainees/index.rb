# frozen_string_literal: true

module PageObjects
  module Trainees
    class Index < PageObjects::Base
      set_url "/trainees"

      element :page_heading, ".govuk-heading-xl"

      element :add_trainee_link, "a", text: "Add a trainee"

      elements :trainee_data, ".govuk-table tbody tr"

      elements :trainee_name, ".govuk-table tbody tr th .govuk-link"
    end
  end
end
