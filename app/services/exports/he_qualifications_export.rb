# frozen_string_literal: true

require "csv"

# Service to export data
module Exports
  class HeQualificationsExport < ExportServiceBase
    def initialize(he_qualifications)
      @report_class = Reports::HeQualificationsReport
      @scope = he_qualifications
    end
  end
end
