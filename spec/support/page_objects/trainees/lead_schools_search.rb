# frozen_string_literal: true

module PageObjects
  module Trainees
    class LeadSchoolsSearch < PageObjects::Base
      set_url "/trainees/{trainee_id}/lead-schools?query={query}"

      element :search_again_option, "input#schools-lead-school-form-lead-school-id-results-search-again-field"
      element :results_search_again_input, "input#schools-lead-school-form-results-search-again-query-field"
      element :zero_results_search_again_input, "input#schools-lead-school-form-no-results-search-again-query-field"
      element :continue, "button[type='submit']"

      def choose_school(id:)
        find("#schools-lead-school-form-lead-school-id-#{id}-field").choose
      end
    end
  end
end
