# frozen_string_literal: true

module PageObjects
  module Trainees
    module EmployingSchools
      module Details
        class Edit < PageObjects::Base
          set_url "/trainees/{trainee_id}/employing-schools/details/edit"

          elements :employing_school_radio_buttons, 'input[type="radio"][name="schools_employing_school_form[employing_school_not_applicable]"]'
          element :continue_button, 'button.govuk-button[type="submit"]'

          def has_employing_school_radio_button_checked?(value)
            radio_button(value).checked?
          end

          def has_employing_school_radio_button_unchecked?(value)
            radio_button(value).unchecked?
          end

          def select_radio_button(value)
            radio_button(value).click
          end

        private

          def radio_button(value)
            employing_school_radio_buttons.detect { |radio| radio.value == value.to_s }
          end
        end
      end
    end
  end
end
