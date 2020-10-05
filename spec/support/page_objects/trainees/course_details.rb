module PageObjects
  module Trainees
    class CourseDetails < PageObjects::Base
      include PageObjects::Helpers

      set_url "/trainees/{id}/course-details"
      element :submit_button, "input[name='commit']"
      element :course_title, "#trainee-course-title-field"
      element :course_phase, "#trainee-course-phase-field"
      element :programme_start_date_day, "#trainee_programme_start_date_3i"
      element :programme_start_date_month, "#trainee_programme_start_date_2i"
      element :programme_start_date_year, "#trainee_programme_start_date_1i"
      element :programme_length, "#trainee-programme-length-field"
      element :programme_end_date_day, "#trainee_programme_end_date_3i"
      element :programme_end_date_month, "#trainee_programme_end_date_2i"
      element :programme_end_date_year, "#trainee_programme_end_date_1i"
      element :allocation_subject, "#trainee-allocation-subject-field"
      element :itt_subject, "#trainee-allocation-subject-field"
      element :employing_school, "#trainee-employing-school-field"
      element :placement_school, "#trainee-placement-school-field"
    end
  end
end
