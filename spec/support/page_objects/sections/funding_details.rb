# frozen_string_literal: true

require_relative "base"

module PageObjects
  module Sections
    class Funding < PageObjects::Sections::Base
      element :link, ".govuk-link"
    end
  end
end
