module PageObjects
  module Trainees
    class IndexPage < PageObjects::BasePage
      set_url "/trainees"

      element :page_title, ".govuk-heading-xl"

      element :add_data_link, "a", text: "Add data to collection"

      elements :trainee_data, ".govuk-table tbody tr"

      elements :trainee_name, ".govuk-table tbody tr th .govuk-link"
    end
  end
end
