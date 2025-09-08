# frozen_string_literal: true

module PageObjects
  module Trainees
    class Deferral < PageObjects::Base
      include PageObjects::Helpers

      set_url "/trainees/{trainee_id}/defer"

      element :defer_date_radios, ".govuk-radios.deferral-date"

      element :defer_date_day, "#deferral_form_date_3i"
      element :defer_date_month, "#deferral_form_date_2i"
      element :defer_date_year, "#deferral_form_date_1i"

      element :continue, "button[type='submit']"
    end
  end
end
