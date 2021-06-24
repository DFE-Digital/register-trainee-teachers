# frozen_string_literal: true

module PageObjects
  module Trainees
    class EditLeadSchool < PageObjects::Base
      set_url "/trainees/{trainee_id}/lead-schools/edit"

      element :lead_school, "#schools-lead-school-form-query-field"
      element :no_js_lead_school, "#schools-lead-school-form-query-field"
      element :autocomplete_list_item, "#schools-lead-school-form-query-field__listbox li:first-child"
      element :submit, 'button.govuk-button[type="submit"]'
    end
  end
end
