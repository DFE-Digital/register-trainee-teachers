# frozen_string_literal: true

module PageObjects
  module Personas
    class Index < PageObjects::Base
      set_url "/personas"

      element :sign_in_button, 'button.govuk-button[type="submit"]'
    end
  end
end
