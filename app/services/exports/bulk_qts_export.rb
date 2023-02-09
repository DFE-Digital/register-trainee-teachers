# frozen_string_literal: true

require "csv"

# Service to export data
module Exports
  class BulkQtsExport < ExportServiceBase
    def initialize(trainees)
      @report_class = Reports::BulkQtsReport
      @scope = trainees
    end
  end
end
