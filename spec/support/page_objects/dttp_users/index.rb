# frozen_string_literal: true

module PageObjects
  module Provider
    module DttpUsers
      class Index < PageObjects::Base
        set_url "system-admin/providers/{id}/dttp_users"

        element :add_a_user, "a", text: "Add a user"
        element :dttp_users_tab, "a", text: "Dttp users"
        element :edit_this_provider, "a", text: "Edit this provider"
        element :register_user, "#register-dttp-user"
        element :unregistered_user_data, ".unregistered-users"

        def unregistered_users
          user_cards(unregistered_user_data)
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
end
