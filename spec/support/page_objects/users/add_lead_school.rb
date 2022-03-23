# frozen_string_literal: true

module PageObjects
  module Users
    class AddLeadSchool < PageObjects::Base
      set_url "/system-admin/users{/id}/lead-schools/new"

      element :lead_school, "#system-admin-user-lead-schools-form-query-field"
      element :no_js_lead_school, "#system-admin-user-lead-schools-form-query-field"
      element :autocomplete_list_item, "#system-admin-user-lead-schools-form-query-field__listbox li:first-child"
      element :submit, 'button.govuk-button[type="submit"]'
    end
  end
end
