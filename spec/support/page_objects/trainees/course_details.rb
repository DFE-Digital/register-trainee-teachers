# frozen_string_literal: true

module PageObjects
  module Trainees
    class CourseDetails < PageObjects::Base
      include PageObjects::Helpers
      set_url "/trainees/{id}/course-details/edit"

      element :subject, "#course-detail-form-subject-field"

      element :course_start_date_day, "#course_detail_form_course_start_date_3i"
      element :course_start_date_month, "#course_detail_form_course_start_date_2i"
      element :course_start_date_year, "#course_detail_form_course_start_date_1i"

      element :course_end_date_day, "#course_detail_form_course_end_date_3i"
      element :course_end_date_month, "#course_detail_form_course_end_date_2i"
      element :course_end_date_year, "#course_detail_form_course_end_date_1i"

      element :main_age_range_3_to_11_course, "#course-detail-form-main-age-range-3-to-11-course-field"
      element :main_age_range_5_to_11_course, "#course-detail-form-main-age-range-5-to-11-course-field"
      element :main_age_range_11_to_16_course, "#course-detail-form-main-age-range-11-to-16-course-field"
      element :main_age_range_11_to_19_course, "#course-detail-form-main-age-range-11-to-19-course-field"
      element :main_age_range_other, "#course-detail-form-main-age-range-other-field"

      element :additional_age_range, "#course-detail-form-additional-age-range-field"

      element :submit_button, "input[name='commit']"
    end
  end
end
