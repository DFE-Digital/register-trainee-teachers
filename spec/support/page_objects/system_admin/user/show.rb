# frozen_string_literal: true

module PageObjects
  module SystemAdmin
    module User
      class Show < PageObjects::Base
        set_url "/system-admin/users/{id}"

        section :provider_access, "#provider-access" do
          elements :remove_access_links, "a.remove-access"
        end

        section :lead_school_access, "#lead-school-access" do
          elements :remove_access_links, "a.remove-access"
        end

        element :delete_user, "a", text: "Delete this user"
        element :flash_message, ".govuk-notification-banner__header"
      end
    end
  end
end
