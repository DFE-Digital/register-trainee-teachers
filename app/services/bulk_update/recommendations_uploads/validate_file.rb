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
          file_encoding_is_accepted?
        else
          record.errors.add(:file, :missing)
        end
      end

    private

      attr_reader :file, :record

      def file_encoding_is_accepted?
        return true if %w[UTF-8 ISO-8859-1].include?(encoding)

        record.errors.add(:file, :encoding_not_accepted, encoding:)
      end

      def detection
        @detection ||= begin
          contents = File.read(file)
          CharlockHolmes::EncodingDetector.detect(contents)
        end
      end

      def encoding
        @encoding ||= detection&.dig(:encoding)
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
