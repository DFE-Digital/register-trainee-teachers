# frozen_string_literal: true

module PageObjects
  class SignIn < PageObjects::Base
    set_url "/sign-in"

    element :page_heading, ".govuk-heading-l"

    element :sign_in_button, ".qa-sign_in_button"

    element :otp_sign_in_button, ".qa-otp_sign_in_button"
  end

  class SignInUserNotFound < PageObjects::Base
    set_url "/sign-in/user-not-found"

    element :page_heading, ".govuk-heading-l"

    element :home_button, "main .govuk-button"
  end
end
