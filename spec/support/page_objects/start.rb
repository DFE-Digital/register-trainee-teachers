# frozen_string_literal: true

module PageObjects
  class Start < PageObjects::Base
    set_url "/"

    element :page_heading, ".govuk-heading-xl"

    section :footer, "footer" do
      element :accessibility_link, ".govuk-footer__link", text: "Accessibility"
    end
  end
end
