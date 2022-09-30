# frozen_string_literal: true

module PageObjects
  module SystemAdmin
    module LeadSchools
      class RemoveAccessConfirmation < PageObjects::Base
        set_url "/system-admin/users/{user_id}/lead-schools/{provider_id}/accessions/edit"

        element :submit, '.govuk-button[type="submit"]'
      end
    end
  end
end
