# frozen_string_literal: true

require "csv"

module Exports
  class PlacementsExport < ExportServiceBase
    def initialize(trainees)
      @report_class = Reports::PlacementsReport
      @scope = trainees
    end
  end
end
