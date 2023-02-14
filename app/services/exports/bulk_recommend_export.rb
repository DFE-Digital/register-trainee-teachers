# frozen_string_literal: true

require "csv"

# Service to export data
module Exports
  class BulkRecommendExport < ExportServiceBase
    def initialize(trainees)
      @report_class = Reports::BulkRecommendReport
      @scope = trainees
    end
  end
end
