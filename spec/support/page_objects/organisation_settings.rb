# frozen_string_literal: true

module PageObjects
  class OrganisationSettings < PageObjects::Base
    set_url "/organisation-settings"

    element :back_link, ".govuk-back-link", text: "Back"
    element :settings_link, "a", text: "Organisation settings"
    element :documentation_link, "a", text: "view and use the Register API technical documentation (opens in new tab)"
    element :token_management_link, "a", text: "Manage your tokens"
  end
end
