# frozen_string_literal: true

module BulkUpdate
  class PlacementsForm
    include ActiveModel::Model
    include ActiveModel::AttributeAssignment
    include ActiveModel::Validations::Callbacks
    include Placements::Config

    validate :validate_file!
    validate :validate_csv!

    def initialize(provider: nil, file: nil)
      @provider = provider
      @file = file
    end

    def save
      return false unless valid?

      @bulk_placement = Placement.create(provider: provider, file: original_csv_sanitised_file)
    end

    def csv
      @csv ||= CSVSafe.new(file.tempfile, **CSV_ARGS).read
    end

    def add_manual_error(type)
      errors.add(:file, type)
    end

    attr_reader :bulk_placement, :provider, :file

  private

    def tempfile
      @_tempfile ||= file&.tempfile
    end

    # no stripping or downcasing of data/headers, just reading with headers expected
    def original_csv_sanitised
      @_original_csv_sanitised ||= begin
        file.tempfile.rewind
        CSVSafe.new(file.tempfile, headers: true, encoding: ENCODING).read
      end
    end

    # write original_csv_sanitised to a new tempfile
    def original_csv_sanitised_file
      @_original_csv_sanitised_file ||= ::ActionDispatch::Http::UploadedFile.new(
        {
          filename: file.original_filename,
          tempfile: sanitised_tempfile,
          type: file.content_type,
        },
      )
    end

    def sanitised_tempfile
      @_sanitised_tempfile ||= begin
        sanitised_file = Tempfile.new(encoding: ENCODING)
        sanitised_file.write(original_csv_sanitised.to_csv.force_encoding(ENCODING))
        sanitised_file.rewind
        sanitised_file
      end
    end

    def validate_file!
      Placements::ValidateFile.new(file: file, record: self).validate!
    end

    def validate_csv!
      return unless tempfile

      Placements::ValidateCsv.new(csv: csv, record: self).validate!
    rescue CSV::MalformedCSVError, Encoding::UndefinedConversionError
      errors.add(:file, :is_not_csv)
    end
  end
end
