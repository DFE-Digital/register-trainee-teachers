# frozen_string_literal: true

require "csv"

module Exports
  class BulkTraineeUploadExport < ExportServiceBase
    def initialize(trainee_upload:)
      @report_class = Reports::BulkTraineeUploadReport
      @scope = trainee_upload
    end
  end
end
