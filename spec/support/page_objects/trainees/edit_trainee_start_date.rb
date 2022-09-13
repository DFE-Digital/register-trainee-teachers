# frozen_string_literal: true

module PageObjects
  module Trainees
    class EditTraineeStartDate < PageObjects::Base
      include PageObjects::Helpers

      set_url "/trainees/{trainee_id}/trainee-start-date/edit"

      element :trainee_start_date_day, "#trainee_start_date_form_trainee_start_date_3i"
      element :trainee_start_date_month, "#trainee_start_date_form_trainee_start_date_2i"
      element :trainee_start_date_year, "#trainee_start_date_form_trainee_start_date_1i"

      element :continue, "button[type='submit']"
    end
  end
end
