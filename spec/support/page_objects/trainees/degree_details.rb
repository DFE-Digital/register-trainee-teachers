module PageObjects
  module Trainees
    class DegreeDetails < PageObjects::Base
      set_url "/trainees/{trainee_id}/degrees/{id}/edit"

      element :degree_subject, "#degree-degree-subject-field"
      element :institution, "#degree-institution-field"
      element :graduation_year, "#degree-graduation-year-field"
      element :degree_grade, ".degree-grade"
      element :degree_country, "#degree-country-field"

      element :error_summary, ".govuk-error-summary"
      element :continue, ".govuk-button"
    end
  end
end
