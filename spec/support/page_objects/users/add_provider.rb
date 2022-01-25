# frozen_string_literal: true

module PageObjects
  module Users
    class AddProvider < PageObjects::Base
      set_url "/system-admin/users{/id}/providers/new"
      element :provider_select, ".provider-select"
      element :submit, 'button.govuk-button[type="submit"]'
    end
  end
end
