# frozen_string_literal: true

module PageObjects
  module Trainees
    class EditEmployingSchool < PageObjects::Base
      set_url "/trainees/{trainee_id}/employing-schools/edit"

      element :employing_school, "#schools-employing-school-form-query-field"
      element :no_js_employing_school, "#schools-employing-school-form-query-field"
      element :autocomplete_list_item, "#schools-employing-school-form-query-field__listbox li:first-child"
      element :not_applicable_checkbox, "#schools-employing-school-form-employing-school-not-applicable-1-field", visible: false
      element :submit, 'button.govuk-button[type="submit"]'
    end
  end
end
