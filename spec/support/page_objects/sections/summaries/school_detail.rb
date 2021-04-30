# frozen_string_literal: true

require_relative "../base"

module PageObjects
  module Sections
    module Summaries
      class SchoolDetail < PageObjects::Sections::Base
        element :lead_school_row, ".govuk-summary-list__row.lead-school"
        element :employing_school_row, ".govuk-summary-list__row.employing-school"
      end
    end
  end
end
