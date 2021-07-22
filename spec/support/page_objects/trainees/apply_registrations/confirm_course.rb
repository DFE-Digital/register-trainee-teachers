# frozen_string_literal: true

module PageObjects
  module Trainees
    module ApplyRegistrations
      class SummaryListRows < SitePrism::Section
        element :key, ".govuk-summary-list__key"
        element :value, ".govuk-summary-list__value"
      end

      class ConfirmCourse < PageObjects::Base
        set_url "/trainees/{id}/apply-application/confirm-course"

        element :confirm, "input[name='apply_applications_confirm_course_form[mark_as_reviewed]']"
        element :submit_button, "button[type='submit']"

        sections :summary_list_rows, SummaryListRows, ".govuk-summary-list__row"

        def subject_description
          subject_row = summary_list_rows.find { |row| row.key.text =~ /Subject/ }
          subject_row.value.text
        end
      end
    end
  end
end
