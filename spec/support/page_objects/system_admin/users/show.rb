# frozen_string_literal: true

module PageObjects
  module SystemAdmin
    module Users
      class Show < PageObjects::Base
        set_url "/system-admin/users/{id}"

        section :providers, "#providers" do
          elements :remove_access_links, "a.remove-access"
        end

        section :lead_partners, "#training-partners" do
          elements :remove_access_links, "a.remove-access"
        end

        element :add_provider, "a.add-user-to-provider"
        element :add_lead_partner, "a.add-user-training-partner"
        element :delete_user, "a", text: "Delete this user"
        element :flash_message, ".app-flash .govuk-notification-banner__header"
      end
    end
  end
end
