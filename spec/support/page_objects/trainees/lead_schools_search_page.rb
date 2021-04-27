# frozen_string_literal: true

module PageObjects
  module Trainees
    class LeadSchoolsSearchPage < PageObjects::Base
      set_url "/trainees/{trainee_id}/lead-schools?query={query}"

      element :continue, "input[name='commit']"

      def choose_school(id:)
        find("#trainee-lead-school-form-lead-school-id-#{id}-field").choose
      end
    end
  end
end
