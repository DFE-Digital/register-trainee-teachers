# frozen_string_literal: true

module PageObjects
  module Trainees
    class EditTraineeStartStatus < PageObjects::Base
      include PageObjects::Helpers

      set_url "/trainees/{trainee_id}/trainee-start-status/edit"

      element :commencement_status_started_on_time, "#trainee-start-status-form-commencement-status-itt-started-on-time-field"
      element :commencement_status_started_later, "#trainee-start-status-form-commencement-status-itt-started-later-field"
      element :commencement_status_not_yet_started, "#trainee-start-status-form-commencement-status-itt-not-yet-started-field"
      element :trainee_start_date_day, "#trainee_start_status_form_trainee_start_date_3i"
      element :trainee_start_date_month, "#trainee_start_status_form_trainee_start_date_2i"
      element :trainee_start_date_year, "#trainee_start_status_form_trainee_start_date_1i"

      element :continue, "button[type='submit']"
    end
  end
end
