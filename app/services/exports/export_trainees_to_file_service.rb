# frozen_string_literal: true

require "csv"

# This service is used to export trainees to a CSV file.
class Exports::ExportTraineesToFileService < ExportToFileServiceBase
  def initialize(path, trainees:)
    @path = path
    @report_service = Exports::ExportTraineesService
    @scope = trainees
  end
end
