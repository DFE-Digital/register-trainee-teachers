# frozen_string_literal: true

module PageObjects
  module Trainees
    class SummaryListRows < SitePrism::Section
      element :key, ".govuk-summary-list__key"
      element :value, ".govuk-summary-list__value"
    end

    class ConfirmPublishCourse < PageObjects::Base
      include PageObjects::Helpers
      set_url "/trainees/{trainee_id}/confirm-publish-course/edit"

      sections :summary_list_rows, SummaryListRows, ".govuk-summary-list__row"

      element :confirm_course_button, "button[type='submit']", text: "Confirm course"
      element :submit_button, "button[type='submit']"

      def subject_description
        subject_row = summary_list_rows.find { |row| row.key.text =~ /Subject/ }
        subject_row.value.text
      end
    end
  end
end
