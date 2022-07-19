# frozen_string_literal: true

require_relative "../sections/user_card"

module PageObjects
  module Providers
    class Show < PageObjects::Base
      set_url "/system-admin/providers/{id}"

      element :edit_this_provider, "a", text: "Edit this provider"
      element :view_funding, "a", text: "View funding"

      element :edit_user_data, ".user-card a"

      sections :user_cards, PageObjects::Sections::UserCard, ".user-card"
    end
  end
end
