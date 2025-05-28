# frozen_string_literal: true

require "csv"

class CsvReportService
  include ServicePattern

  def initialize(report_class, scope:)
    @report_class = report_class
    @scope = scope
  end

  def call
    write_to_csv
  end

private

  attr_accessor :report_class, :path, :csv, :scope

  def write_to_csv
    CSV.generate(**csv_options) do |csv|
      report_generator_class = report_class.new(csv, scope:)
      report_generator_class.generate_report
      @csv = csv
    end
  end

  def csv_options
    report_class.try(:csv_options) || {}
  end
end
