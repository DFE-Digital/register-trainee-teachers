# frozen_string_literal: true

require "rails_helper"

module ConfirmPublishCourse
  describe View do
    include SummaryHelper
    include CourseDetailsHelper

    include_examples "rendering course confirmation"
  end
end
