# frozen_string_literal: true

require "csv"

module Exports
  class BulkPlacementExport < ExportServiceBase
    def initialize(trainees)
      @report_class = Reports::BulkPlacementReport
      @scope = trainees
    end
  end
end
