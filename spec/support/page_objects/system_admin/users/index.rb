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
        element :search, "#search-field", visible: :all
        element :submit_search, ".submit-search"
        sections :users, UserRow, ".user-row"
        element :flash_message, ".govuk-notification-banner__header"
        element :flash_message, ".govuk-notification-banner__header"

        def body_text_excluding_search
          Capybara.current_session.text.gsub(search.text, "")
        end
      end
    end
  end
end
