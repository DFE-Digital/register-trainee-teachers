# frozen_string_literal: true

module PageObjects
  module SystemAdmin
    module Schools
      class Edit < PageObjects::Base
        set_url "/system-admin/schools/{id}/edit"

        element :error_summary, ".govuk-error-summary"
        element :continue_button, 'button.govuk-button[type="submit"]'
        element :back_link, ".govuk-back-link", text: "Back"
        element :cancel_link, ".govuk-link", text: "Cancel and return to record"

        elements :lead_partner_radio_buttons, 'input[type="radio"][name="school[lead_partner]"]'

        def has_lead_partner_radio_button_checked?(value)
          radio_button(value).checked?
        end

        def select_radio_button(value)
          radio_button(value).click
        end

      private

        def radio_button(value)
          lead_partner_radio_buttons.detect { |radio| radio.value == value.to_s }
        end
      end
    end
  end
end
