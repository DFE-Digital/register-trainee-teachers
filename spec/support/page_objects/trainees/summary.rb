require_relative "../sections/personal_details"

module PageObjects
  module Trainees
    class Summary < PageObjects::Base
      set_url "/trainees/{id}"

      section :personal_details, PageObjects::Sections::PersonalDetails, ".personal-details"
      section :contact_details, PageObjects::Sections::ContactDetails, ".contact-details"
      section :course_details, PageObjects::Sections::CourseDetails, ".course-details"
      section :training_details, PageObjects::Sections::TrainingDetails, ".training-details"
      element :degree_link, ".education .degree-link .govuk-link"

      element :submit_for_trn_button, "input[name='commit']"
    end
  end
end
