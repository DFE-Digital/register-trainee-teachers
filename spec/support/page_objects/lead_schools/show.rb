# frozen_string_literal: true

module PageObjects
  module LeadSchools
    class Show < PageObjects::Base
      set_url "/system-admin/lead-schools/{id}"

      element :add_a_user, "a", text: "Add a user"
      element :edit_user_data, "a", text: "Edit"
    end
  end
end
