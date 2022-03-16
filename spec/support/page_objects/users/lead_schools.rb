# frozen_string_literal: true

module PageObjects
  module Users
    class LeadSchools < PageObjects::Base
      set_url "/system-admin/users/{id}/lead_schools"

      element :search_again_option, "input#system-admin-user-lead-schools-form-lead-school-id-results-search-again-field"
      element :results_search_again_input, "input#system-admin-user-lead-schools-form-results-search-again-query-field"
      element :no_results_search_again_input, "input#system-admin-user-lead-schools-form-no-results-search-again-query-field"
      element :continue, "button[type='submit']"

      def choose_school(id:)
        find("#system-admin-user-lead-schools-form-lead-school-id-#{id}-field").choose
      end
    end
  end
end
