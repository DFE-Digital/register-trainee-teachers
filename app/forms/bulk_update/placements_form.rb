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
      return @_sanitised_tempfile if defined?(@_sanitised_tempfile)

      @_sanitised_tempfile = Tempfile.new(encoding: ENCODING)

      # Set the encoding of the data being written to UTF-8
      sanitised_data = original_csv_sanitised.to_csv.force_encoding(ENCODING)

      # write and re-wind
      @_sanitised_tempfile.write(sanitised_data)
      @_sanitised_tempfile.rewind
      @_sanitised_tempfile
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
