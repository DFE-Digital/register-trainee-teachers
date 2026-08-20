# frozen_string_literal: true

module PageObjects
  module Trainees
    class EmployingSchoolsSearch < PageObjects::Base
      set_url "/trainees/{trainee_id}/employing-schools?query={query}"

      element :search_again_option, "input[id$='employing-school-id-results-search-again-field']"
      element :results_search_again_input, "input[id$='results-search-again-query-field']"
      element :zero_results_search_again_input, "input[id$='no-results-search-again-query-field']"
      element :continue, "button[type='submit']"

      def choose_school(id:)
        find("[id$='employing-school-id-#{id}-field']").choose
      end
    end
  end
end
