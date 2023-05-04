# frozen_string_literal: true

module BulkUpdate
  class RecommendationsUploadForm
    include ActiveModel::Model
    include ActiveModel::AttributeAssignment
    include ActiveModel::Validations::Callbacks
    include RecommendationsUploads::Config

    validate :validate_file!
    validate :validate_csv!

    def initialize(provider: nil, file: nil)
      @provider = provider
      @file = file
    end

    def save
      return false unless valid?

      @recommendations_upload = RecommendationsUpload.create(provider: provider, file: original_csv_sanitised_file)
    end

    def csv
      @csv ||= CSVSafe.new(file.tempfile, **CSV_ARGS).read
    end

    attr_reader :recommendations_upload, :provider, :file

  private

    def tempfile
      @tempfile ||= file&.tempfile
    end

    # no stripping or downcasing of data/headers, just reading with headers expected
    def original_csv_sanitised
      @original_csv_sanitised ||= begin
        file.tempfile.rewind
        CSVSafe.new(file.tempfile, headers: true, encoding: ENCODING).read
      end
    end

    # write original_csv_sanitised to a new tempfile
    def original_csv_sanitised_file
      return @original_csv_sanitised_file if defined?(@original_csv_sanitised_file)

      sanitised_tempfile = Tempfile.new(encoding: ENCODING)

      # Set the encoding of the data being written to UTF-8
      sanitised_data = original_csv_sanitised.to_csv.force_encoding(ENCODING)
      sanitised_tempfile.write(sanitised_data)
      sanitised_tempfile.rewind

      # Return the temporary file as an UploadedFile expected by RecommendationsUpload
      # with the original content type and file name from the initial upload
      @original_csv_sanitised_file = ::ActionDispatch::Http::UploadedFile.new(
        {
          filename: file.original_filename,
          tempfile: sanitised_tempfile,
          type: file.content_type,
        },
      )
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
