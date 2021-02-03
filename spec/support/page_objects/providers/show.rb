# frozen_string_literal: true

module PageObjects
  module Providers
    class Show < PageObjects::Base
      set_url "system-admin/providers/{id}"

      element :add_a_user, "a", text: "Add a user"

      elements :user_data, ".user-card"
    end
  end
end
