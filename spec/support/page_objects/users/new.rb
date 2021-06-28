# frozen_string_literal: true

module PageObjects
  module Users
    class New < PageObjects::Base
      set_url "system-admin/providers/{id}/users/new"

      element :first_name, "#user-first-name-field"
      element :last_name, "#user-last-name-field"
      element :email, "#user-email-field"
      element :dttp_id, "#user-dttp-id-field"

      element :error_summary, ".govuk-error-summary"

      element :submit, 'button.govuk-button[type="submit"]'
    end
  end
end
