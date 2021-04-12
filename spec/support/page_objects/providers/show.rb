# frozen_string_literal: true

module PageObjects
  module Providers
    class Show < PageObjects::Base
      set_url "system-admin/providers/{id}"

      element :add_a_user, "a", text: "Add a user"

      elements :user_data, ".user-card"

      elements :dttp_users_not_registered_data, "#user-not-registered"
    end
  end
end
