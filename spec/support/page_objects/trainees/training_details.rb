# frozen_string_literal: true

module PageObjects
  module Trainees
    class TrainingDetails < PageObjects::Base
      include PageObjects::Helpers

      set_url "/trainees/{id}/training-details/edit"

      element :trainee_id, "#training-details-form-trainee-id-field"
      element :commencement_date_day, "#training_details_form_commencement_date_3i"
      element :commencement_date_month, "#training_details_form_commencement_date_2i"
      element :commencement_date_year, "#training_details_form_commencement_date_1i"

      element :commencement_date_radio_option_course, "input[name='training_details_form[commencement_date_radio_option]'][value='course']"
      element :commencement_date_radio_option_manual, "input[name='training_details_form[commencement_date_radio_option]'][value='manual']"

      element :submit_button, "button[type='submit']"
    end
  end
end
