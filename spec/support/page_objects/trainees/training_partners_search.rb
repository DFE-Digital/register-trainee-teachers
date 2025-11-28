# frozen_string_literal: true

module PageObjects
  module Trainees
    class TrainingPartnersSearch < PageObjects::Base
      set_url "/trainees/{trainee_id}/training-partners?query={query}"

      element :search_again_option, "input#partners-training-partner-form-lead-partner-id-results-search-again-field"
      element :results_search_again_input, "input#partners-training-partner-form-results-search-again-query-field"
      element :zero_results_search_again_input, "input#partners-training-partner-form-no-results-search-again-query-field"
      element :continue, "button[type='submit']"

      def choose_training_partner(id:)
        find("#partners-training-partner-form-lead-partner-id-#{id}-field").choose
      end
    end
  end
end
