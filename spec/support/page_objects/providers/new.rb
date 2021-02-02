# frozen_string_literal: true

module PageObjects
  module Providers
    class New < PageObjects::Base
      set_url "system-admin/providers/new"

      element :name, "#provider-name-field"
      element :dttp_id, "#provider-dttp-id-field"

      element :submit, 'input.govuk-button[type="submit"]'
    end
  end
end
