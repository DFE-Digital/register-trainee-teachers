# frozen_string_literal: true

require_relative "../base"

module PageObjects
  module Sections
    module Summaries
      class DegreeDetail < PageObjects::Sections::Base
        element :type, ".govuk-summary-list__row.degree-type .govuk-summary-list__value"
        element :subject, ".govuk-summary-list__row.subject .govuk-summary-list__value"
        element :institution, ".govuk-summary-list__row.institution .govuk-summary-list__value"
        element :graduation_year, ".govuk-summary-list__row.graduation-year .govuk-summary-list__value"
        element :gradie, ".govuk-summary-list__row.grade .govuk-summary-list__value"
        element :delete_degree, ".app-summary-card__header .govuk-button--link"
      end
    end
  end
end
