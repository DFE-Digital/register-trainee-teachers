require_relative "../sections/personal_details"

module PageObjects
  module Trainees
    class Summary < PageObjects::Base
      set_url "/trainees/{id}"

      section :personal_details, PageObjects::Sections::PersonalDetails, ".app-task-list__item.personal-details"
      section :contact_details, PageObjects::Sections::ContactDetails, ".contact-details"
      section :training_details, PageObjects::Sections::TrainingDetails, ".training-details"
      section :degree_details, PageObjects::Sections::DegreeDetails, ".degree-details"

      element :submit_for_trn_button, "input[name='commit']"
    end
  end
end
