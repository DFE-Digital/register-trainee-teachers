# frozen_string_literal: true

require_relative "base"

module PageObjects
  module Sections
    class ContactDetails < PageObjects::Sections::Base
      element :address, ".address .govuk-summary-list__value"
      element :postcode, ".postcode .govuk-summary-list__value"
      element :phone_number, ".phone-number .govuk-summary-list__value"
      element :email, ".email .govuk-summary-list__value"
    end
  end
end
