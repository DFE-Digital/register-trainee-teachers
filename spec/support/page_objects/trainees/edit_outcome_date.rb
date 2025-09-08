# frozen_string_literal: true

module PageObjects
  module Trainees
    class EditOutcomeDate < PageObjects::Base
      include PageObjects::Helpers

      set_url "/trainees/{trainee_id}/outcome-details/outcome-date/edit"

      element :outcome_date_radios, ".govuk-radios.outcome-date"

      element :outcome_date_day, "#outcome_date_form_date_3i"
      element :outcome_date_month, "#outcome_date_form_date_2i"
      element :outcome_date_year, "#outcome_date_form_date_1i"

      element :continue, "button[type='submit']"
    end
  end
end
