# frozen_string_literal: true

module PageObjects
  class EditCookiePreferences < PageObjects::Base
    set_url "/cookie-preferences/edit"

    element :back_link, ".govuk-back-link"
    element :page_heading, ".govuk-heading-l"
    element :yes_option, "#cookie-preferences-form-consent-yes-field"
    element :submit_button, "button[type='submit']"
  end
end
