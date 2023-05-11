# frozen_string_literal: true

module PageObjects
  module SystemAdmin
    module TraineeDeletions
      class Confirmation < PageObjects::Base
        set_url "/system-admin/trainee-deletions/confirmations/{id}"

        element :confirm, "button[type='submit']"
      end
    end
  end
end
