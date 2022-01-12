# frozen_string_literal: true

module PageObjects
  module LeadSchools
    class Index < PageObjects::Base
      set_url "/system-admin/lead-schools"

      section :lead_school_card, PageObjects::Sections::ProviderCard, ".lead_school-card"
      element :lead_school_links, ".govuk-table__body .govuk-table__row .govuk-link"
    end
  end
end
