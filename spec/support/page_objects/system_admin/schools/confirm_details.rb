# frozen_string_literal: true

module PageObjects
  module SystemAdmin
    module Schools
      class ConfirmDetails < PageObjects::Base
        set_url "/system-admin/schools/{id}/confirm"

        element :confirm_button, 'button.govuk-button[type="submit"]'
      end
    end
  end
end
