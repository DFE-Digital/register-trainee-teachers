# frozen_string_literal: true

module PageObjects
  module Trainees
    class CourseDetails < PageObjects::Base
      include PageObjects::Helpers
      set_url "/trainees/{id}/course-details/edit"

      element :subject, "#course-details-form-subject-field"
      element :subject_raw, "input[data-nameoriginal='course_details_form[subject_raw]']"

      element :course_start_date_day, "#course_details_form_course_start_date_3i"
      element :course_start_date_month, "#course_details_form_course_start_date_2i"
      element :course_start_date_year, "#course_details_form_course_start_date_1i"

      element :course_end_date_day, "#course_details_form_course_end_date_3i"
      element :course_end_date_month, "#course_details_form_course_end_date_2i"
      element :course_end_date_year, "#course_details_form_course_end_date_1i"

      element :main_age_range_3_to_11_course, "#course-details-form-main-age-range-3-to-11-course-field"
      element :main_age_range_5_to_11_course, "#course-details-form-main-age-range-5-to-11-course-field"
      element :main_age_range_11_to_16_course, "#course-details-form-main-age-range-11-to-16-course-field"
      element :main_age_range_11_to_19_course, "#course-details-form-main-age-range-11-to-19-course-field"
      element :main_age_range_other, "#course-details-form-main-age-range-other-field"

      element :additional_age_range, "#course-details-form-additional-age-range-field"

      element :submit_button, "input[name='commit']"
    end
  end
end
