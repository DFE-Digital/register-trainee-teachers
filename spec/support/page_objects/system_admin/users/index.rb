# frozen_string_literal: true

module PageObjects
  module SystemAdmin
    module Users
      class Index < PageObjects::Base
        set_url "/system-admin/users"

        class UserRow < SitePrism::Section
          element :link, ".user-link"
        end

        element :add_a_user, "a", text: "Add a user"
        element :search, "#user-search-form-user-field"
        element :first_option, "#user-search-form-user-field__option--0"
        sections :users, UserRow, ".user-row"
        element :flash_message, ".govuk-notification-banner__header"
        element :flash_message, ".govuk-notification-banner__header"
      end
    end
  end
end
