# frozen_string_literal: true

module PageObjects
  module SystemAdmin
    module User
      class Show < PageObjects::Base
        set_url "/system-admin/users/{id}"
        element :delete_user, "a", text: "Delete this user"
      end
    end
  end
end
