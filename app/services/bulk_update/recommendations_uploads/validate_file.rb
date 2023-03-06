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
          record.errors.add(:file, "Please select a file")
        end
      end

    private

      def file_size_within_range?
        if file.size > 1.megabyte
          record.errors.add(:base, "File must be no greater than 1MB")
        elsif file.empty?
          record.errors.add(:base, "File cannot be empty")
        end
      end

      attr_reader :file, :record
    end
  end
end
