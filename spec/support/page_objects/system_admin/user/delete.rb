# frozen_string_literal: true

module PageObjects
  module SystemAdmin
    module User
      class Delete < PageObjects::Base
        set_url "/system-admin/users/{id}/delete"
        element :delete_button, ".govuk-button--warning"
      end
    end
  end
end
