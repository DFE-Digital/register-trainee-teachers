# frozen_string_literal: true

module PageObjects
  module Trainees
    class EditLeadSchool < PageObjects::Base
      set_url "/trainees/{trainee_id}/lead-schools/edit"

      element :lead_school, "#schools-autocomplete"
      element :autocomplete_list_item, "#schools-autocomplete__listbox li:first-child"
      element :submit, 'input.govuk-button[type="submit"]'
    end
  end
end
