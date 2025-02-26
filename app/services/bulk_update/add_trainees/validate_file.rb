# frozen_string_literal: true

module BulkUpdate
  module AddTrainees
    class ValidateFile
      def initialize(file:, record:)
        @file = file
        @record = record
      end

      def validate!
        if file
          file_size_within_range? && valid_csv? && file_encoding_is_accepted?
        else
          record.errors.add(:file, :missing)
          false
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
          detect_encoding(contents)
        end
      end

      def detect_encoding(contents)
        # Try to detect UTF-8 first
        if contents.force_encoding("UTF-8").valid_encoding?
          return { encoding: "UTF-8" }
        end
        
        # Try ISO-8859-1 (Latin-1) which accepts any byte sequence
        if contents.force_encoding("ISO-8859-1").valid_encoding?
          return { encoding: "ISO-8859-1" }
        end
        
        # Default to binary if we can't determine the encoding
        { encoding: "BINARY" }
      end

      def encoding
        @encoding ||= detection&.dig(:encoding)
      end

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
        file.tempfile.rewind
        CSVSafe.new(file.tempfile, **BulkUpdate::BulkAddTraineesUploadForm::CSV_ARGS).read
        true
      rescue CSV::MalformedCSVError
        record.errors.add(:file, :is_not_csv)
        false
      end
    end
  end
end
