# frozen_string_literal: true

module PageObjects
  module Trainees
    class DegreeType < PageObjects::Base
      set_url "/trainees/{trainee_id}/degrees/new/type"

      element :error_summary, ".govuk-error-summary"
      element :continue, "input[name='commit']"
    end
  end
end
