module PageObjects
  module Trainees
    class Degrees < PageObjects::Base
      set_url "trainees/{trainee_id}/degrees/new"

      element  :degree_type, ".degree_type"

      element  :type_of_uk_degrees, "#degree-uk-degree-field"
      element  :type_of_non_uk_degrees, "#degree-locale-code-non-uk-conditional"

      element :continue, ".govuk-button"
    end
  end
end
