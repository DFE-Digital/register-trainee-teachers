# frozen_string_literal: true

module PageObjects
  module Trainees
    class SummaryListRows < SitePrism::Section
      element :key, ".govuk-summary-list__key"
      element :value, ".govuk-summary-list__value"
    end

    class ConfirmCourseDetails < PageObjects::Base
      set_url "/trainees/{trainee_id}/course-details/confirm"

      element :confirm, "input[name='confirm_detail_form[mark_as_completed]']"
      element :continue_button, "button[type='submit']", text: "Continue"

      sections :summary_list_rows, SummaryListRows, ".govuk-summary-list__row"

      def subject_description
        subject_row = summary_list_rows.find { |row| row.key.text =~ /Subject/ }
        subject_row.value.text
      end
    end
  end
end
