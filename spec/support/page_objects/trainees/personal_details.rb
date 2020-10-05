module PageObjects
  module Trainees
    class PersonalDetails < PageObjects::Base
      include PageObjects::Helpers

      set_url "/trainees/{id}/personal-details/edit"
      element :first_names, "input[name='personal_details_form[first_names]']"
      element :last_name, "input[name='personal_details_form[last_name]']"
      element :dob_day, "input[name='personal_details_form[date_of_birth(3i)]']"
      element :dob_month, "input[name='personal_details_form[date_of_birth(2i)]']"
      element :dob_year, "input[name='personal_details_form[date_of_birth(1i)]']"
      element :gender, ".govuk-radios.gender"
      element :nationality, ".govuk-checkboxes.nationality"
      element :submit_button, "input[name='commit']"
    end
  end
end
