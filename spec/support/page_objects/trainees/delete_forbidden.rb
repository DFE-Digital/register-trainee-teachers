# frozen_string_literal: true

module PageObjects
  module Trainees
    class DeleteForbidden < PageObjects::Base
      include PageObjects::Helpers

      set_url "/trainees/{id}/delete-forbidden"

      element :defer_option, "#trainee-forbidden-delete-form-alternative-option-defer-field"
      element :withdraw_option, "#trainee-forbidden-delete-form-alternative-option-withdraw-field"
      element :exit_option, "#trainee-forbidden-delete-form-alternative-option-exit-field"

      element :submit_button, "button[type='submit']"
    end
  end
end
