# frozen_string_literal: true

module Exports
  class BlankPlacementExport < ExportServiceBase
    def initialize
      @report_class = Reports::BulkPlacementReport
      @scope = Trainee.none
    end
  end
end
