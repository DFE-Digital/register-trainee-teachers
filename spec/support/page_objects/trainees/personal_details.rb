# frozen_string_literal: true

module PageObjects
  module Trainees
    class PersonalDetails < PageObjects::Base
      include PageObjects::Helpers

      set_url "/trainees/{id}/personal-details/edit"
      element :first_names, "#personal-details-form-first-names-field"
      element :last_name, "#personal-details-form-last-name-field"
      element :dob_day, "#personal_details_form_date_of_birth_3i"
      element :dob_month, "#personal_details_form_date_of_birth_2i"
      element :dob_year, "#personal_details_form_date_of_birth_1i"
      element :gender, ".govuk-radios.gender"
      element :nationality, ".govuk-checkboxes.nationality"
      element :other_nationality, "#personal-details-form-other-nationality1-field"
      element :other_nationality1_raw, "input[data-nameoriginal='personal_details_form[other_nationality1_raw]']"
      element :other_nationality2_raw, "input[data-nameoriginal='personal_details_form[other_nationality2_raw]']"
      element :other_nationality3_raw, "input[data-nameoriginal='personal_details_form[other_nationality3_raw]']"
      element :add_nationality, "#add-nationality-button"
      element :continue_button, "input[name='commit'][value='Continue']"
    end
  end
end
