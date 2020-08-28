# frozen_string_literal: true

require_relative "base"

module PageObjects
  module Sections
    class HomeHero < PageObjects::Sections::Base
      element :text, ".govuk-body"
    end
  end
end
