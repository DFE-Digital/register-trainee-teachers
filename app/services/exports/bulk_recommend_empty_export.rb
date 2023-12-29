# frozen_string_literal: true

require "csv"

# Service to export data
module Exports
  class BulkRecommendEmptyExport < ExportServiceBase
    def initialize
      @report_class = Reports::BulkRecommendEmptyReport
      @scope = []
    end
  end
end
