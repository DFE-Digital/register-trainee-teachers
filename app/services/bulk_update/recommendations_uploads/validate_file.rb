# frozen_string_literal: true

require "charlock_holmes"

module BulkUpdate
  module RecommendationsUploads
    class ValidateFile
      def initialize(file:, record:)
        @file = file
        @record = record
      end

      def validate!
        if file
          file_size_within_range?
          file_type_is_utf8?
        else
          record.errors.add(:file, :missing)
        end
      end

    private

      attr_reader :file, :record

      def file_type_is_utf8?
        return true if detection&.dig(:encoding) == "UTF-8"

        record.errors.add(:file, :non_utf_8) # rubocop:disable Naming/VariableNumber
      end

      def detection
        @detection ||= begin
          contents = File.read(file)
          CharlockHolmes::EncodingDetector.detect(contents)
        end
      end

      def file_size_within_range?
        if file.size > 1.megabyte
          record.errors.add(:file, :too_large)
        elsif file.size.zero? # rubocop:disable Style/ZeroLengthPredicate
          record.errors.add(:file, :empty)
        end
      end
    end
  end
end
