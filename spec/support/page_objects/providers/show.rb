# frozen_string_literal: true

module PageObjects
  module Providers
    class Show < PageObjects::Base
      set_url "/system-admin/providers/{id}"

      element :add_a_user, "a", text: "Add a user"
      element :edit_this_provider, "a", text: "Edit this provider"

      element :register_user, "#register-dttp-user"

      element :registered_user_data, ".registered-users"
      element :unregistered_user_data, ".unregistered-users"
      element :edit_user_data, ".registered-users .user-card a"

      def registered_users
        user_cards(registered_user_data)
      end

    private

      def user_cards(element_node)
        within(element_node) do
          find_all(".user-card")
        end
      end
    end
  end
end
