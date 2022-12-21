# frozen_string_literal: true

module PageObjects
  module Reports
    class PerformanceProfiles < PageObjects::Base
      set_url "/reports/performance-profiles"

      element :export_link, ".govuk-button", text: "Export new trainee data (CSV)"
    end
  end
end
