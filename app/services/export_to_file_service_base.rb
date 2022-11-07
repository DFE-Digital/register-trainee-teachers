# frozen_string_literal: true

require "csv"

# This service is used to export to a CSV file.
class ExportToFileServiceBase
  include ServicePattern

  def initialize(report_service, path, scope:)
    @path = path
    @report_service = report_service
    @scope = scope
  end

  def call
    raise("No path specified") if path.nil?

    File.write(path, report_service.call(scope))
  end

private

  attr_reader :path, :report_service, :scope
end
