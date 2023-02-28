# frozen_string_literal: true

module BulkUpdate
  module RecommendationsUploads
    class ValidateCsv
      def initialize(csv)
        @csv = csv
      end

      # do all required headers exist in the CSV headers
      def valid?
        csv_headers_set.superset?(VALID_HEADERS_SET)
      end

    private

      attr_reader :csv

      VALID_HEADERS_SET = ::Set[
        "TRN",
        "Date QTS or EYTS standards met",
      ].freeze

      def csv_headers_set
        @csv_headers_set ||= ::Set.new(csv.headers)
      end
    end
  end
end
