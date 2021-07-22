# frozen_string_literal: true

require "rails_helper"

module ApplyApplications
  module ConfirmCourse
    describe View do
      include SummaryHelper
      include CourseDetailsHelper

      include_examples "rendering course confirmation"
    end
  end
end
