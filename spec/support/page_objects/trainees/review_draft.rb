# frozen_string_literal: true

require_relative "../sections/personal_details"
require_relative "../sections/diversity"

module PageObjects
  module Trainees
    class ReviewDraft < PageObjects::Base
      set_url "/trainees/{id}/review-draft"

      STATUS_COMPLETED = "Status Completed"

      section :personal_details, PageObjects::Sections::PersonalDetails, ".app-task-list__item.personal-details"
      section :apply_trainee_data, PageObjects::Sections::ApplyTraineeData, ".app-task-list__item.trainee-data"
      section :contact_details, PageObjects::Sections::ContactDetails, ".contact-details"
      section :diversity_section, PageObjects::Sections::Diversity, ".app-task-list__item.diversity-details"
      section :degree_details, PageObjects::Sections::DegreeDetails, ".degree-details"
      section :course_details, PageObjects::Sections::CourseDetails, ".app-task-list__item.course-details"
      section :training_details, PageObjects::Sections::TrainingDetails, ".training-details"
      section :funding_section, PageObjects::Sections::Funding, ".app-task-list__item.funding"
      section :lead_and_employing_schools_section, PageObjects::Sections::SchoolsDetails, ".app-task-list__item.school-details"
      section :iqts_country_section, PageObjects::Sections::IqtsCountry, ".app-task-list__item.iqts-country-details"

      element :review_this_record_link, "#check-details"
      element :delete_this_draft_link, ".app-link--warning"

      def has_personal_details_completed?
        personal_details.status.text == STATUS_COMPLETED
      end

      def has_contact_details_completed?
        contact_details.status.text == STATUS_COMPLETED
      end

      def has_diversity_information_completed?
        diversity_section.status.text == STATUS_COMPLETED
      end

      def has_degree_details_completed?
        degree_details.status.text == STATUS_COMPLETED
      end

      def has_course_details_completed?
        course_details.status.text == STATUS_COMPLETED
      end

      def has_training_details_completed?
        training_details.status.text == STATUS_COMPLETED
      end

      def has_lead_and_employing_school_information_completed?
        lead_and_employing_schools_section.status.text == STATUS_COMPLETED
      end
    end
  end
end
