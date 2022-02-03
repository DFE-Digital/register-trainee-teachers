# frozen_string_literal: true

module PageObjects
  module Users
    class AddLeadSchool < PageObjects::Base
      set_url "/system-admin/users{/id}/lead-schools/new"
      element :lead_school_select, ".lead-school-select"
      element :submit, 'button.govuk-button[type="submit"]'
    end
  end
end
