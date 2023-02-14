# frozen_string_literal: true

module PageObjects
  module Reports
    class BulkQts < PageObjects::Base
      set_url "/reports/trainees-you-can-recommend"

      element :export_link, ".govuk-button", text: "Export trainee data"
    end
  end
end
