# frozen_string_literal: true

module PageObjects
  module Trainees
    class EditLeadPartner < PageObjects::Base
      set_url "/trainees/{trainee_id}/lead-partners/edit"

      element :lead_partner, "#partners-lead-partner-form-query-field"
      element :lead_partner_no_js, "#partners-lead-partner-form-query-field"
      element :autocomplete_list_item, "#partners-lead-partner-form-query-field__listbox li:first-child"
      element :not_applicable_checkbox, "#partners-lead-partner-form-lead-partner-not-applicable-1-field", visible: false
      element :submit, 'button.govuk-button[type="submit"]'
    end
  end
end
