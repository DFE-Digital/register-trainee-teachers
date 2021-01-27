# frozen_string_literal: true

require_relative "base"

module PageObjects
  module Sections
    class ProviderCard < PageObjects::Sections::Base
      element :name, ".govuk-link"
    end
  end
end
