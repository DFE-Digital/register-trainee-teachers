module PageObjects
  module Personas
    class Index < PageObjects::Base
      set_url "/personas"

      element :sign_in_button, 'input.govuk-button[type="submit"]'
    end
  end
end
