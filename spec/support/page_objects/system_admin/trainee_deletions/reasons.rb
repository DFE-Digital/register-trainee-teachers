# frozen_string_literal: true

module PageObjects
  module SystemAdmin
    module TraineeDeletions
      class Reasons < PageObjects::Base
        set_url "/system-admin/trainee-deletions/reasons/{id}"

        class ReasonRadio < SitePrism::Section
          element :input, "input"
          element :label, "label"
        end

        sections :delete_reasons, ReasonRadio, ".govuk-radios__item"

        element :continue, "button[type='submit']"
      end
    end
  end
end
