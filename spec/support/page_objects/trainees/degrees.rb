module PageObjects
  module Trainees
    class Degrees < PageObjects::Base
      set_url "/trainees/{trainee_id}/degrees/new"

      element :uk_degree_type, "#degree-locale-code-uk-field"
      element :non_uk_degree_type, "#degree-locale-code-non-uk-field"

      element :type_of_uk_degrees, "#degree-uk-degree-field"
      element :type_of_non_uk_degrees, "#degree-locale-code-non-uk-conditional"

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
