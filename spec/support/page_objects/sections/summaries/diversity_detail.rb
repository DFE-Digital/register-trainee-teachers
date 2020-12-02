# frozen_string_literal: true

require_relative "../base"

module PageObjects
  module Sections
    module Summaries
      class DiversityDetail < PageObjects::Sections::Base
        element :information, ".govuk-summary-list__row.diversity-information .govuk-summary-list__value"
        element :ethnicity, ".govuk-summary-list__row.ethnicity .govuk-summary-list__value"
        element :disability, ".govuk-summary-list__row.disability .govuk-summary-list__value"
      end
    end
  end
end
