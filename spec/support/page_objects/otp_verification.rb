# frozen_string_literal: true

module PageObjects
  class OtpVerification < PageObjects::Base
    set_url "/sign-in-code"

    element :page_heading, ".govuk-heading-l"

    element :submit, 'button.govuk-button[type="submit"]'

    element :code, "#otp-verifications-form-code-field"
  end
end
