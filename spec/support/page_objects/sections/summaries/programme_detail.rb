# frozen_string_literal: true

require_relative "../base"

module PageObjects
  module Sections
    module Summaries
      class ProgrammeDetail < PageObjects::Sections::Base
        element :subject_row, ".govuk-summary-list__row.subject"
        element :age_range_row, ".govuk-summary-list__row.age-range"
        element :start_date_row, ".govuk-summary-list__row.programme-start-date"
        element :end_date_row, ".govuk-summary-list__row.programme-end-date"
      end
    end
  end
end
