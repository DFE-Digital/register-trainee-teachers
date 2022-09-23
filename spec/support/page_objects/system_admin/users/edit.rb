# frozen_string_literal: true

module PageObjects
  module SystemAdmin
    module Users
      class Edit < PageObjects::Base
        set_url "system-admin/providers/{provider_id}/users/{id}/edit"

        element :email, "#user-email-field"
        element :error_summary, ".govuk-error-summary"
        element :submit, 'button.govuk-button[type="submit"]'
      end
    end
  end
end
