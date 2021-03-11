# frozen_string_literal: true

module PageObjects
  module Trainees
    class ConfirmDetails < PageObjects::Base
      set_url "/trainees/{id}/{section}/confirm"
      element :confirm, "input[name='confirm_detail_form[mark_as_completed]']"
      element :submit_button, "input[name='commit']"
      element :continue_button, "input[name='commit'][value='Continue']"
      element :update_record_button, "input[name='commit'][value='Update record']"
      element :delete_button, "input[name='commit'][value='Delete degree']"
    end
  end
end
