module PageObjects
  class Start < PageObjects::Base
    set_url "/"

    element :page_title, ".govuk-heading-xl"
  end
end
