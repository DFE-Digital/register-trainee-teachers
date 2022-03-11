# frozen_string_literal: true

module PageObjects
  module Users
    class UserRow < SitePrism::Section
      element :link, ".user-link"
    end

    class Index < PageObjects::Base
      set_url "/system-admin/users"

      element :add_a_user, "a", text: "Add a user"

      sections :users, UserRow, ".user-row"
    end
  end
end
