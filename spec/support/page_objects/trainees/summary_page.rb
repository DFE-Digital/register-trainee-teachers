require_relative "../sections/personal_details"

module PageObjects
  module Trainees
    class SummaryPage < PageObjects::BasePage
      set_url "/trainees/{id}"

      section :personal_details, PageObjects::Sections::PersonalDetails, ".personal-details"
      section :contact_details, PageObjects::Sections::ContactDetails, ".contact-details"
    end
  end
end
