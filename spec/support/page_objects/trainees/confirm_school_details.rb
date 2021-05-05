# frozen_string_literal: true

module PageObjects
  module Trainees
    class ConfirmSchoolDetails < PageObjects::Base
      set_url "/trainees/{id}/lead-school/confirm"

      element :continue, "input[name='commit']"
    end
  end
end
