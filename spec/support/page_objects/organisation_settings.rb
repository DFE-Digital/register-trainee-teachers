# frozen_string_literal: true

module PageObjects
  class OrganisationSettings < PageObjects::Base
    set_url "/organisation-settings"

    element :back_link, ".govuk-back-link", text: "Back"
    element :settings_link, "a", text: "Organisation settings"
  end
end
