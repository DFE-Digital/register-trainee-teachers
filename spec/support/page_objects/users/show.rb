# frozen_string_literal: true

module PageObjects
  module Users
    class Show < PageObjects::Base
      set_url "/system-admin/users{/id}"
      element :add_provider, "a.add-user-to-provider"
      element :add_lead_school, "a.add-user-lead-school"
      elements :providers, ".provider-row dd a"
      elements :lead_schools, ".lead-school-row dd a"
      element :delete_user, "a", text: "Delete this user"
    end
  end
end
