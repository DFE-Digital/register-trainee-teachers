# frozen_string_literal: true

module PageObjects
  module SystemAdmin
    module Uploads
      class New < PageObjects::Base
        set_url "system-admin/uploads/new"

        element :file, "#upload-file-field"
        element :error_summary, ".govuk-error-summary"
        element :submit, 'button.govuk-button[type="submit"]'
      end
    end
  end
end
