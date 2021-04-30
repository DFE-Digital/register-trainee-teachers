# frozen_string_literal: true

module PageObjects
  module Trainees
    class EmployingSchoolsSearch < PageObjects::Base
      set_url "/trainees/{trainee_id}/employing-schools?query={query}"

      element :search_again_option, "input#employing-school-form-employing-school-id-results-search-again-field"
      element :results_search_again_input, "input#employing-school-form-results-search-again-query-field"
      element :no_results_search_again_input, "input#employing-school-form-no-results-search-again-query-field"
      element :continue, "input[name='commit']"

      def choose_school(id:)
        find("#employing-school-form-employing-school-id-#{id}-field").choose
      end
    end
  end
end
