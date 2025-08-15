# frozen_string_literal: true

require "charlock_holmes"

module BulkUpdate
  module AddTrainees
    class ValidateFile
      def initialize(file:, record:)
        @file   = file
        @record = record
      end

      def validate!
        if file
          file_size_within_range? && valid_csv?
        else
          record.errors.add(:file, :missing)
          false
        end
      end

    private

      attr_reader :file, :record

      def file_size_within_range?
        if file.size > 1.megabyte
          record.errors.add(:file, :too_large)
          return false
        elsif file.size.zero? # rubocop:disable Style/ZeroLengthPredicate
          record.errors.add(:file, :empty)
          return false
        end
        true
      end

      def valid_csv?
        CSVSafe.new(file.read, **BulkUpdate::BulkAddTraineesUploadForm::CSV_ARGS).read
        true
      rescue CSV::MalformedCSVError
        record.errors.add(:file, :is_not_csv)
        false
      end
    end
  end
end
