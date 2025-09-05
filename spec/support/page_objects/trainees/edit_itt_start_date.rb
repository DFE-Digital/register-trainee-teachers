# frozen_string_literal: true

module PageObjects
  module Trainees
    class EditIttDates < PageObjects::Base
      include PageObjects::Helpers

      set_url "/trainees/{trainee_id}/course-details/itt-dates/edit"

      element :start_date_day, "#itt_dates_form_start_date_3i"
      element :start_date_month, "#itt_dates_form_start_date_2i"
      element :start_date_year, "#itt_dates_form_start_date_1i"

      element :end_date_day, "#itt_dates_form_end_date_3i"
      element :end_date_month, "#itt_dates_form_end_date_2i"
      element :end_date_year, "#itt_dates_form_end_date_1i"

      element :continue, "button[type='submit']"
    end
  end
end
