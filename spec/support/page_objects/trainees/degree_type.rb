# frozen_string_literal: true

module PageObjects
  module Trainees
    class DegreeType < PageObjects::Base
      set_url "/trainees/{trainee_id}/degrees/new/type"

      element :uk_degree, "#degree-locale-code-uk-field"
      element :non_uk_degree, "#degree-locale-code-non-uk-field"

      element :error_summary, ".govuk-error-summary"
      element :continue, "input[name='commit']"
    end
  end
end
