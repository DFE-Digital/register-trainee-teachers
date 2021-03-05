# frozen_string_literal: true

module PageObjects
  module Trainees
    class Reinstatement < PageObjects::Base
      include PageObjects::Helpers

      set_url "/trainees/{id}/reinstate"

      element :reinstate_date_day, "#reinstatement_form_date_3i"
      element :reinstate_date_month, "#reinstatement_form_date_2i"
      element :reinstate_date_year, "#reinstatement_form_date_1i"

      element :continue, "input[name='commit']"
    end
  end
end
