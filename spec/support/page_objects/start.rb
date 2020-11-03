module PageObjects
  class Start < PageObjects::Base
    set_url "/"

    element :page_heading, ".govuk-heading-xl"
  end
end
