# frozen_string_literal: true

require_relative "base"

module PageObjects
  module Sections
    class UserCard < PageObjects::Sections::Base
      element :button, ".govuk-button--warning"
    end
  end
end