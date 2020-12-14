# frozen_string_literal: true

module PageObjects
  module Trainees
    class PersonalDetails < PageObjects::Base
      include PageObjects::Helpers

      set_url "/trainees/{id}/personal-details/edit"
      element :first_names, "#personal-detail-first-names-field"
      element :last_name, "#personal-detail-last-name-field"
      element :dob_day, "#personal_detail_date_of_birth_3i"
      element :dob_month, "#personal_detail_date_of_birth_2i"
      element :dob_year, "#personal_detail_date_of_birth_1i"
      element :gender, ".govuk-radios.gender"
      element :nationality, ".govuk-checkboxes.nationality"
      element :continue_button, "input[name='commit'][value='Continue']"
    end
  end
end
