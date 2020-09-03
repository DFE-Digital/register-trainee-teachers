# frozen_string_literal: true

require_relative "base"

module PageObjects
  module Sections
    class TrainingDetails < PageObjects::Sections::Base
      element :start_date, ".start-date .govuk-summary-list__value"
      element :full_time_part_time, ".full-time-part-time .govuk-summary-list__value"
      element :teaching_scholars, ".teaching-scholars .govuk-summary-list__value"
    end
  end
end
