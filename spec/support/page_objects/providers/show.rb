# frozen_string_literal: true

require_relative "../sections/user_card"
module PageObjects
  module Providers
    class Show < PageObjects::Base
      set_url "/system-admin/providers/{id}"

      element :add_a_user, "a", text: "Add a user"
      element :edit_this_provider, "a", text: "Edit this provider"
      element :view_funding, "a", text: "View funding"

      element :register_user, "#register-dttp-user"

      element :unregistered_user_data, ".unregistered-users"
      element :edit_user_data, ".registered-users .user-card a"

      sections :registered_user_cards, PageObjects::Sections::UserCard, ".registered-users .user-card"
    end
  end
end
