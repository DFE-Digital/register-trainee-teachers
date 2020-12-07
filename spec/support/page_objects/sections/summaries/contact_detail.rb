# frozen_string_literal: true

require_relative "../base"

module PageObjects
  module Sections
    module Summaries
      class ContactDetail < PageObjects::Sections::Base
        element :address, ".govuk-summary-list__row.address .govuk-summary-list__value"
        element :email, ".govuk-summary-list__row.email-address .govuk-summary-list__value"
      end
    end
  end
end
