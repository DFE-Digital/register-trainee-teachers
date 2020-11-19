# frozen_string_literal: true

module PageObjects
  module Trainees
    class ConfirmDetails < PageObjects::Base
      set_url "/trainees/{id}/{section}/confirm"
      element :confirm, "input[name='confirm_detail[mark_as_completed]']"
      element :submit_button, "input[name='commit']"
    end
  end
end
