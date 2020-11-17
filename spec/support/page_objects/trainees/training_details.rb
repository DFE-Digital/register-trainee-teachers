# frozen_string_literal: true

module PageObjects
  module Trainees
    class TrainingDetails < PageObjects::Base
      include PageObjects::Helpers

      set_url "/trainees/{id}/training-details"
      element :submit_button, "input[name='commit']"
      element :start_date_day, "#trainee_start_date_3i"
      element :start_date_month, "#trainee_start_date_2i"
      element :start_date_year, "#trainee_start_date_1i"
      element :part_time, "#trainee-full-time-part-time-part-time-field"
      element :full_time, "#trainee-full-time-part-time-full-time-field"
      element :teaching_scholars_yes, "#trainee-teaching-scholars-true-field"
      element :teaching_scholars_no, "#trainee-teaching-scholars-field"
    end
  end
end
