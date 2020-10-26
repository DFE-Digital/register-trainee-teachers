module PageObjects
  module Trainees
    class DegreeAsk < PageObjects::Base
      set_url "/trainees/{trainee_id}/degrees/ask"

      element :locale_code_uk, "#degree-locale-code-uk-field"
      element :locale_code_non_uk, "#degree-locale-code-non-uk-field"

      element :error_summary, ".govuk-error-summary"
      element :continue, ".govuk-button"
    end
  end
end
