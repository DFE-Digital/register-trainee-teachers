# frozen_string_literal: true

module PageObjects
  module Trainees
    class LeadSchoolsSearch < PageObjects::Base
      set_url "/trainees/{trainee_id}/lead-schools?query={query}"

      element :search_again_option, "input#lead-school-form-lead-school-id-results-search-again-field"
      element :results_search_again_input, "input#lead-school-form-results-search-again-query-field"
      element :no_results_search_again_input, "input#lead-school-form-no-results-search-again-query-field"
      element :continue, "input[name='commit']"

      def choose_school(id:)
        find("#lead-school-form-lead-school-id-#{id}-field").choose
      end
    end
  end
end
