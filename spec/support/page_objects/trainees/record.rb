# frozen_string_literal: true

module PageObjects
  module Trainees
    class Record < PageObjects::Base
      set_url "/trainees/{id}"

      element :timeline_tab, "a", text: "Timeline"
      element :personal_details_tab, "a", text: "Personal details and education"
      element :admin_tab, "a", text: "Admin"

      element :trainee_name, ".govuk-heading-xl"
      element :trn_status, ".govuk-tag.trainee-status", match: :first

      element :add_degree, ".degree-details .govuk-button"
      element :record_outcome, ".govuk-button.recommend-for-award"
      element :reinstate, ".govuk-link.reinstate"
      element :withdraw, ".govuk-link.withdraw"
      element :undo_withdrawal, "a", text: "Undo withdrawal"
      element :defer, ".govuk-link.defer"
      element :delete, ".govuk-link.delete"

      section :record_detail, PageObjects::Sections::Summaries::RecordDetail, ".record-details"
      section :course_detail, PageObjects::Sections::Summaries::CourseDetail, ".course-details"
      section :school_detail, PageObjects::Sections::Summaries::SchoolDetail, ".school-details"

      section :personal_detail, PageObjects::Sections::Summaries::PersonalDetail, ".personal-details"
      section :contact_detail, PageObjects::Sections::Summaries::ContactDetail, ".contact-details"
      section :diversity_detail, PageObjects::Sections::Summaries::DiversityDetail, ".diversity-details"
      section :degree_detail, PageObjects::Sections::Summaries::DegreeDetail, ".degree-details"

      element :change_lead_partner, "a", text: "Change lead partner", visible: false
      element :change_employing_school, "a", text: "Change employing school", visible: false
      element :change_course_details, "a", text: "Change course", visible: false
      element :change_trainee_status, "a", text: "Change status", visible: false
      element :change_date_of_deferral, "a", text: "Change date of deferral", visible: false
      element :withdrawal_details_component, "h3", text: "Withdrawal details", visible: false
      element :enable_editing, ".enable-editing"
    end
  end
end
