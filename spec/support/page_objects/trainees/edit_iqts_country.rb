# frozen_string_literal: true

module PageObjects
  module Trainees
    class EditIqtsCountry < PageObjects::Base
      set_url "/trainees/{trainee_id}/iqts-country/edit"

      element :iqts_country, "#iqts-country-form-iqts-country-field"
      element :continue_button, 'button.govuk-button[type="submit"]'
    end
  end
end
