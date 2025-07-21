# frozen_string_literal: true

module Reports
  class BulkRecommendEmptyReport < TemplateClassCsv
    # required headers
    TRN = "TRN"
    PROVIDER_TRAINEE_ID = "Provider trainee ID"

    IDENTIFIERS = [TRN, PROVIDER_TRAINEE_ID].freeze
    DATE = "Date QTS or EYTS requirement met"

    DEFAULT_HEADERS = [
      *IDENTIFIERS,
      DATE,
    ].freeze

    def initialize(csv, scope:)
      @csv = csv
      @scope = scope
    end

    def headers
      @headers ||= DEFAULT_HEADERS
    end

  private

    def add_headers
      csv << headers
    end

    def add_report_rows; end
  end
end
