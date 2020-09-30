module PageObjects
  module Trainees
    class PersonalDetails < PageObjects::Base
      set_url "/trainees/{id}/personal-details"
      element :first_names, "#trainee-first-names-field"
      element :last_name, "#trainee-last-name-field"
      element :dob_day, "#trainee_date_of_birth_3i"
      element :dob_month, "#trainee_date_of_birth_2i"
      element :dob_year, "#trainee_date_of_birth_1i"
      element :gender, ".govuk-radios.gender"
      element :nationality, ".govuk-checkboxes.nationality"
      element :submit_button, "input[name='commit']"
    end
  end
end
