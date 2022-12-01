# frozen_string_literal: true

module PageObjects
  module Trainees
    class ConfirmIqtsCountry < PageObjects::Base
      set_url "/trainees/{id}/iqts-country/confirm"

      element :confirm, "input[name='confirm_detail_form[mark_as_completed]']"
      element :continue, "button[type='submit']"
    end
  end
end
