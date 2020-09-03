module PageObjects
  module Trainees
    class TrainingDetails < PageObjects::BasePage
      set_url "/trainees/{id}/training-details"
      element :submit_button, "input[name='commit']"
      element :start_date_day, "input[name='trainee[start_date(3i)]']"
      element :start_date_month, "input[name='trainee[start_date(2i)]']"
      element :start_date_year, "input[name='trainee[start_date(1i)]']"
      element :part_time, "#trainee-full-time-part-time-part-time-field"
      element :full_time, "#trainee-full-time-part-time-full-time-field"
      element :teaching_scholars_yes, "#trainee-teaching-scholars-true-field"
      element :teaching_scholars_no, "#trainee-teaching-scholars-field"
    end
  end
end
