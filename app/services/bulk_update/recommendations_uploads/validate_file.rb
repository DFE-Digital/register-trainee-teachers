# frozen_string_literal: true

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
        else
          record.errors.add(:file, :missing)
        end
      end

    private

      def file_size_within_range?
        if file.size > 1.megabyte
          record.errors.add(:file, :too_large)
        elsif file.size.zero? # rubocop:disable Style/ZeroLengthPredicate
          record.errors.add(:file, :empty)
        end
      end

      attr_reader :file, :record
    end
  end
end
