# frozen_string_literal: true

module PageObjects
  module Trainees
    class EditEmployingSchool < PageObjects::Base
      set_url "/trainees/{trainee_id}/employing-schools/edit"

      element :employing_school, "#schools-employing-school-form-employing-school-id-field"
      element :no_js_employing_school, "#schools-employing-school-form-employing-school-id-field"
      element :autocomplete_list_item, "#schools-employing-school-form-employing-school-id-field__listbox li:first-child"
      element :submit, 'input.govuk-button[type="submit"]'
    end
  end
end
