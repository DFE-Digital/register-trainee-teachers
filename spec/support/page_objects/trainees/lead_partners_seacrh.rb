# frozen_string_literal: true

module PageObjects
  module Trainees
    class LeadPartnersSearch < PageObjects::Base
      set_url "/trainees/{trainee_id}/lead-schools?query={query}"

      element :search_again_option, "input#partners-lead-partner-form-lead-partner-id-results-search-again-field"
      element :results_search_again_input, "input#partners-lead-partner-form-results-search-again-query-field"
      element :zero_results_search_again_input, "input#partners-lead-partner-form-no-results-search-again-query-field"
      element :continue, "button[type='submit']"

      def choose_lead_partner(id:)
        find("#partners-lead-partner-form-lead-partner-id-#{id}-field").choose
      end
    end
  end
end
