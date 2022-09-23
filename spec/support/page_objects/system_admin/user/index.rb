# frozen_string_literal: true

module PageObjects
  module SystemAdmin
    module User
      class Index < PageObjects::Base
        set_url "/system-admin/users"
        element :flash_message, ".govuk-notification-banner__header"
      end
    end
  end
end
