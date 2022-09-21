# frozen_string_literal: true

module PageObjects
  module Users
    class AddProviderLink < SitePrism::Section
      element :link, ".add-provider-to-user"
    end

    class AddLeadSchoolLink < SitePrism::Section
      element :link, ".add-lead-school-to-user"
    end

    class Show < PageObjects::Base
      set_url "/system-admin/users{/id}"
      element :add_provider, "a", text: "Add provider"
      element :add_lead_school, "a", text: "Add lead school"
      elements :providers, ".provider-row dd a"
      elements :lead_schools, ".lead-school-row dd a"
      element :delete_user, "a", text: "Delete this user"
    end
  end
end
