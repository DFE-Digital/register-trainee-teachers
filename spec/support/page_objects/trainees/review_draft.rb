# frozen_string_literal: true

require_relative "../sections/personal_details"
require_relative "../sections/diversity"

module PageObjects
  module Trainees
    class ReviewDraft < PageObjects::Base
      set_url "/trainees/{id}/review-draft"

      section :training_details, PageObjects::Sections::TrainingDetails, ".training-details"
      section :programme_details, PageObjects::Sections::ProgrammeDetails, ".app-task-list__item.programme-details"
      section :personal_details, PageObjects::Sections::PersonalDetails, ".app-task-list__item.personal-details"
      section :contact_details, PageObjects::Sections::ContactDetails, ".contact-details"
      section :diversity_section, PageObjects::Sections::Diversity, ".app-task-list__item.diversity-details"
      section :degree_details, PageObjects::Sections::DegreeDetails, ".degree-details"

      element :review_this_record_link, "#check-details"
    end
  end
end
