module PageObjects
  module Trainees
    class EditDegreeDetails < PageObjects::Base
      set_url "/trainees/{trainee_id}/degrees/{id}/edit"

      element :subject, "#degree-subject-field"
      element :institution, "#degree-institution-field"
      element :graduation_year, "#degree-graduation-year-field"
      element :grade, ".degree-grade"
      element :country, "#degree-country-field"

      element :error_summary, ".govuk-error-summary"
      element :continue, ".govuk-button"
    end
  end
end
