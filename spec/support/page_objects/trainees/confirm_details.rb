# frozen_string_literal: true

module PageObjects
  module Trainees
    class ConfirmDetails < PageObjects::Base
      set_url "/trainees/{id}/{section}/confirm"

      element :change, "#training-partner .govuk-link", text: "Change"
      element :confirm, "input[name='confirm_detail_form[mark_as_completed]']"
      element :submit_button, "button[type='submit']"
      element :continue_button, "button[type='submit']", text: "Continue"
      element :update_record_button, "button[type='submit']", text: "Update record"
      element :delete_button, "input[name='commit'][value='Delete degree']"
    end
  end
end
