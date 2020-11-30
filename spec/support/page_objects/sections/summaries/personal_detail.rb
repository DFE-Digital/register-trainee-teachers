# frozen_string_literal: true

require_relative "../base"

module PageObjects
  module Sections
    module Summaries
      class PersonalDetail < PageObjects::Sections::Base
        element :full_name, ".govuk-summary-list__row.full-name .govuk-summary-list__value"
        element :dob, ".govuk-summary-list__row.date-of-birth .govuk-summary-list__value"
        element :gender, ".govuk-summary-list__row.gender .govuk-summary-list__value"
        element :nationality, ".govuk-summary-list__row.nationality .govuk-summary-list__value"
      end
    end
  end
end
