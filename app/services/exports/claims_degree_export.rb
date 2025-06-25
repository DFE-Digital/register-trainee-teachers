# frozen_string_literal: true

require "csv"

module Exports
  class ClaimsDegreeExport < ExportServiceBase
    def initialize(degrees, from_date: nil, to_date: nil)
      @report_class = Reports::ClaimsDegreeReport
      @scope = degrees
      @from_date = from_date
      @to_date = to_date
    end

    def call
      CsvReportService.call(report_class, scope:)
    end
  end
end
