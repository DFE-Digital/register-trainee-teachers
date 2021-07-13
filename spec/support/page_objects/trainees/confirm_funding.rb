# frozen_string_literal: true

module PageObjects
  module Trainees
    class ConfirmFunding < PageObjects::Base
      set_url "/trainees/{id}/funding/confirm"

      element :confirm, "input[name='confirm_detail_form[mark_as_completed]']"
      element :continue, "button[type='submit']"
    end
  end
end
