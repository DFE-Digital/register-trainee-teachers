# frozen_string_literal: true

module PageObjects
  module Trainees
    class EditTrainingPartner < PageObjects::Base
      set_url "/trainees/{trainee_id}/training-partners/edit"

      element :training_partner, "#partners-training-partner-form-query-field"
      element :training_partner_no_js, "#partners-training-partner-form-query-field"
      element :autocomplete_list_item, "#partners-training-partner-form-query-field__listbox li:first-child"
      element :not_applicable_checkbox, "#partners-training-partner-form-lead-partner-not-applicable-1-field", visible: false
      element :submit, 'button.govuk-button[type="submit"]'
    end
  end
end
