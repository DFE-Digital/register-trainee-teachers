# frozen_string_literal: true

module PageObjects
  class SignIn < PageObjects::Base
    set_url "/sign-in"

    element :page_heading, ".govuk-heading-l"

    element :sign_in_button, ".qa-sign_in_button"
  end

  class SignInFallback < PageObjects::Base
    set_url "/sign-in/fallback"
  end
end
