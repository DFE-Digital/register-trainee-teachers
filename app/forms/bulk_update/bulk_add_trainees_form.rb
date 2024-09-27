# frozen_string_literal: true

module BulkUpdate
  class BulkAddTraineesForm
    include ActiveModel::Model
    include ActiveModel::AttributeAssignment
    include ActiveModel::Validations::Callbacks

    validate :validate_file!
    validate :validate_csv!

    def initialize(provider: nil, file: nil)
      @provider = provider
      @file = file
    end

    def save
      return false unless valid?

      # TODO: Implement the save method
      true
    end

    def csv
      @csv ||= CSVSafe.new(file.tempfile, **CSV_ARGS).read
    end

    attr_reader :file

  private

    def tempfile
      @tempfile ||= file&.tempfile
    end

    def original_csv_sanitised
      @original_csv_sanitised ||= begin
        file.tempfile.rewind
        CSVSafe.new(file.tempfile, headers: true, encoding: ENCODING).read
      end
    end

    def validate_file!
      RecommendationsUploads::ValidateFile.new(file: file, record: self).validate!
    end

    def validate_csv!
      return unless tempfile

      RecommendationsUploads::ValidateCsv.new(csv: csv, record: self).validate!
    rescue CSV::MalformedCSVError, Encoding::UndefinedConversionError
      errors.add(:file, :is_not_csv)
    end
  end
end
