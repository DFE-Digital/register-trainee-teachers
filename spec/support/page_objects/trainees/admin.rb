# frozen_string_literal: true

module PageObjects
  module Trainees
    class Admin < PageObjects::Base
      set_url "/trainees/{id}/admin"

      element :collection_name, ".govuk-summary-list__key"
      element :collection, "details"
    end
  end
end
