# frozen_string_literal: true

require_relative "../sections/personal_details"
require_relative "../sections/diversity"

module PageObjects
  module Trainees
    class ReviewDraft < PageObjects::Base
      set_url "/trainees/{id}/review-draft"

      section :course_details, PageObjects::Sections::CourseDetails, ".app-task-list__item.course-details"
      section :personal_details, PageObjects::Sections::PersonalDetails, ".app-task-list__item.personal-details"
      section :contact_details, PageObjects::Sections::ContactDetails, ".contact-details"
      section :diversity_section, PageObjects::Sections::Diversity, ".app-task-list__item.diversity-details"
      section :degree_details, PageObjects::Sections::DegreeDetails, ".degree-details"
      section :training_details, PageObjects::Sections::TrainingDetails, ".training-details"

      element :review_this_record_link, "#check-details"
      element :delete_this_draft_link, ".app-link--warning"
    end
  end
end
