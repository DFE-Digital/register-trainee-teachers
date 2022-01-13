# frozen_string_literal: true

module PageObjects
  module Users
    class AddProviderLink < SitePrism::Section
      element :link, ".add-provider-to-user"
    end

    class Show < PageObjects::Base
      set_url "/system-admin/users{/id}"
      element :add_provider, "a", text: "Add provider"
      elements :providers, '.provider-row dd a'
      # sections :add_provider, AddProviderLink, ".provider-row"
    end
  end
end
