# frozen_string_literal: true

module PageObjects
  module Trainees
    class EditIttStartDate < PageObjects::Base
      include PageObjects::Helpers
      set_url "/trainees/{trainee_id}/course-details/start-date/edit"

      element :itt_start_date_radios, ".govuk-radios.itt_start-date"

      element :itt_start_date_day, "#itt_start_date_form_date_3i"
      element :itt_start_date_month, "#itt_start_date_form_date_2i"
      element :itt_start_date_year, "#itt_start_date_form_date_1i"

      element :continue, "button[type='submit']"
    end
  end
end
