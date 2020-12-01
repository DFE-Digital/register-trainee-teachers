# frozen_string_literal: true

module PageObjects
  class Start < PageObjects::Base
    set_url "/"

    element :page_heading, ".govuk-heading-xl"

    element :sign_in, ".app-link--inverted"

    element :phase_banner, ".govuk-phase-banner"

    section :footer, "footer" do
      element :accessibility_link, ".govuk-footer__link", text: "Accessibility"
      element :cookies_link, ".govuk-footer__link", text: "Cookies"
      element :privacy_link, ".govuk-footer__link", text: "Privacy policy"
    end
  end
end
