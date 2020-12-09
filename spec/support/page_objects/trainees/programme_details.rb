# frozen_string_literal: true

module PageObjects
  module Trainees
    class ProgrammeDetails < PageObjects::Base
      include PageObjects::Helpers
      set_url "/trainees/{id}/programme-details/edit"

      element :subject, "#programme-detail-subject-field"

      element :programme_start_date_day, "#programme_detail_programme_start_date_3i"
      element :programme_start_date_month, "#programme_detail_programme_start_date_2i"
      element :programme_start_date_year, "#programme_detail_programme_start_date_1i"

      element :programme_end_date_day, "#programme_detail_programme_end_date_3i"
      element :programme_end_date_month, "#programme_detail_programme_end_date_2i"
      element :programme_end_date_year, "#programme_detail_programme_end_date_1i"

      element :main_age_range_3_to_11_programme, "#programme-detail-main-age-range-3-to-11-programme-field"
      element :main_age_range_5_to_11_programme, "#programme-detail-main-age-range-5-to-11-programme-field"
      element :main_age_range_11_to_16_programme, "#programme-detail-main-age-range-11-to-16-programme-field"
      element :main_age_range_11_to_19_programme, "#programme-detail-main-age-range-11-to-19-programme-field"
      element :main_age_range_other, "#programme-detail-main-age-range-other-field"

      element :additional_age_range, "#programme-detail-additional-age-range-field"

      element :submit_button, "input[name='commit']"
    end
  end
end
