# frozen_string_literal: true

module PageObjects
  module SystemAdmin
    module Uploads
      class Show < PageObjects::Base
        set_url "/system-admin/uploads/{id}"

        element :delete_upload, ".govuk-button--warning"
        element :download, "a", text: "Download"
      end
    end
  end
end
