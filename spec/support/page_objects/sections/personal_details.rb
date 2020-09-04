# frozen_string_literal: true

require_relative "base"

module PageObjects
  module Sections
    class PersonalDetails < PageObjects::Sections::Base
      element :trainee_id, ".trainee-id > .govuk-summary-list__value"
    end
  end
end
