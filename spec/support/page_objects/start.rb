# frozen_string_literal: true

module PageObjects
  class Start < PageObjects::Base
    set_url "/"

    element :organisation_name, ".govuk-caption-l"
    element :page_heading, ".govuk-heading-l"

    element :sign_in, ".app-start-page-banner__button"

    element :request_an_account, ".app-link--request-account"

    element :phase_banner, ".govuk-phase-banner"

    section :footer, "footer" do
      element :news_and_updates_link, ".govuk-footer__link", text: "News and updates"
      element :how_to_use_this_service_link, ".govuk-footer__link", text: "How to use this service"
      element :api_docs_link, ".govuk-footer__link", text: "API documentation"
      element :csv_docs_link, ".govuk-footer__link", text: "CSV documentation"
      element :reference_data_link, ".govuk-footer__link", text: "Reference data"
      element :accessibility_link, ".govuk-footer__link", text: "Accessibility"
      element :cookies_link, ".govuk-footer__link", text: "Cookies"
      element :privacy_link, ".govuk-footer__link", text: "Privacy"
    end

    section :primary_navigation, "nav.govuk-service-navigation__wrapper" do
      element :drafts_link, ".govuk-link", text: "Draft trainees"
    end
  end
end
