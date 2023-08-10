# frozen_string_literal: true

module PageObjects
  module Providers
    class New < PageObjects::Base
      set_url "system-admin/providers/new"

      element :name, "#provider-name-field"
      element :dttp_id, "#provider-dttp-id-field"
      element :ukprn, "#provider-ukprn-field"
      element :accreditation_id, "#provider-accreditation-id-field"
      element :apply_sync_enabled, "#provider-apply-sync-enabled-true-field"

      element :submit, 'button.govuk-button[type="submit"]', text: "Continue"
    end
  end
end
