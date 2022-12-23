# frozen_string_literal: true

module PageObjects
  class Otp < PageObjects::Base
    set_url "/request-sign-in-code"

    element :page_heading, ".govuk-heading-l"

    element :submit, 'button.govuk-button[type="submit"]'

    element :email, "#otp-form-email-field"
  end
end
