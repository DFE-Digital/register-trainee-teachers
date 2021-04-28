# frozen_string_literal: true

module PageObjects
  module Trainees
    class EmployingSchoolsSearch < PageObjects::Base
      set_url "/trainees/{trainee_id}/employing-schools?query={query}"

      element :continue, "input[name='commit']"

      def choose_school(id:)
        find("#employing-school-form-employing-school-id-#{id}-field").choose
      end
    end
  end
end
