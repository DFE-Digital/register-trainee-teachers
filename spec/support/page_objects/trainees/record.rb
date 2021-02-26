# frozen_string_literal: true

module PageObjects
  module Trainees
    class Record < PageObjects::Base
      set_url "/trainees/{id}"

      element :timeline_tab, "a", text: "Timeline"

      element :trainee_name, ".govuk-heading-xl"
      element :trn_status, ".govuk-tag.trainee-status", match: :first

      element :record_outcome, ".record-actions > .govuk-button"
      element :withdraw, ".govuk-link.withdraw"

      element :defer, ".govuk-link.defer"

      section :record_detail, PageObjects::Sections::Summaries::RecordDetail, ".record-details"
      section :programme_detail, PageObjects::Sections::Summaries::ProgrammeDetail, ".programme-details"

      section :personal_detail, PageObjects::Sections::Summaries::PersonalDetail, ".personal-details"
      section :contact_detail, PageObjects::Sections::Summaries::ContactDetail, ".contact-details"
      section :diversity_detail, PageObjects::Sections::Summaries::DiversityDetail, ".diversity-details"
      section :degree_detail, PageObjects::Sections::Summaries::DegreeDetail, ".degree-details"
    end
  end
end
