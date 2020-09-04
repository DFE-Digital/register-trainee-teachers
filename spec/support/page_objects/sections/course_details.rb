# frozen_string_literal: true

require_relative "base"

module PageObjects
  module Sections
    class CourseDetails < PageObjects::Sections::Base
      element :course_title, ".course-title .govuk-summary-list__value"
    end
  end
end
