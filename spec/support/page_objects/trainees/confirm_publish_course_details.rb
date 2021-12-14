# frozen_string_literal: true

module PageObjects
  module Trainees
    class SummaryListRows < SitePrism::Section
      element :key, ".govuk-summary-list__key"
      element :value, ".govuk-summary-list__value"
    end

    class ConfirmPublishCourseDetails < PageObjects::Base
      set_url "/trainees/{trainee_id}/publish-course-details/confirm"

      element :confirm, "input[name='confirm_detail_form[mark_as_completed]']"
      element :continue_button, "button[type='submit']"
      element :enter_an_answer_for_itt_end_date_link, "a[name$=' end date']"

      sections :summary_list_rows, SummaryListRows, ".govuk-summary-list__row"

      def subject_description
        summary_list_rows.find { |row| row.key.text =~ /Subject/ }&.value&.text
      end
    end
  end
end
