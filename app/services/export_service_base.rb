# frozen_string_literal: true

require "csv"

# Service to export data
class ExportServiceBase
  include ServicePattern

  def initialize(report_class, scope:)
    @report_class = report_class
    @scope = scope
  end

  def call
    CsvReportService.call(report_class, scope:)
  end

private

  attr_reader :report_class, :scope
end
