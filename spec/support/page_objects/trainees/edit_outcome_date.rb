# frozen_string_literal: true

module PageObjects
  module Trainees
    class EditOutcomeDate < PageObjects::Base
      include PageObjects::Helpers
      set_url "/trainees/{trainee_id}/outcome-details/outcome-date/edit"

      element :outcome_date_radios, ".govuk-radios.outcome-date"

      element :outcome_date_day, "#outcome_date_form_outcome_date_3i"
      element :outcome_date_month, "#outcome_date_form_outcome_date_2i"
      element :outcome_date_year, "#outcome_date_form_outcome_date_1i"

      element :continue, "input[name='commit']"
    end
  end
end
