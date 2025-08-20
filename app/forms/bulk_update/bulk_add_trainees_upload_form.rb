# frozen_string_literal: true

module BulkUpdate
  class BulkAddTraineesUploadForm
    attr_reader :provider, :file, :upload

    include ActiveModel::Model
    include BulkUpdate::AddTrainees::Config

    validate :validate_file!
    validate :validate_csv!

    def initialize(provider: nil, file: nil)
      @provider = provider
      @file     = enforce_utf8(file)
      @upload   = build_upload
    end

    def save
      return false unless valid?

      upload.attributes = upload_attributes

      upload.save!
    end

  private

    def enforce_utf8(file)
      return if file.nil?

      tempfile = file.tempfile

      tempfile.rewind

      contents = tempfile.read.force_encoding(Encoding::ASCII_8BIT)

      if contents.present?
        detection     = CharlockHolmes::EncodingDetector.detect(contents)
        utf8_contents = CharlockHolmes::Converter.convert(contents, detection.fetch(:encoding, ENCODING), ENCODING)

        tempfile.rewind
        tempfile.truncate(0)
        tempfile.write(utf8_contents)
      end

      tempfile.rewind

      file
    end

    def upload_attributes
      {
        provider:,
        file:,
        number_of_trainees:,
      }
    end

    def csv
      return if errors[:file].present?

      file.tempfile.rewind

      @csv ||= CSV.read(file.tempfile, **CSV_ARGS)
    end

    def validate_file!
      BulkUpdate::AddTrainees::ValidateFile.new(file: file, record: self).validate!
    end

    def validate_csv!
      return false unless csv

      BulkUpdate::AddTrainees::ValidateCsv.new(csv: csv, record: self).validate!
    end

    def number_of_trainees
      @number_of_trainees ||= csv.entries.reject { |entry| entry.to_h.values.all?(&:blank?) }.count
    end

    def build_upload
      BulkUpdate::TraineeUpload.new(version: VERSION)
    end
  end
end
