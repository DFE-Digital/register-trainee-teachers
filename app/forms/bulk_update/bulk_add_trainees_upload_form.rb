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
      @file     = file
      @upload   = build_upload
    end

    def save
      return false unless valid?

      upload.attributes = upload_attributes
      upload.save!
    end

  private

    def upload_attributes
      {
        provider:,
        file:,
        number_of_trainees:,
      }
    end

    def csv
      return if file.nil? || errors[:file].present?

      file.tempfile.rewind

      @csv ||= CSVSafe.new(file.tempfile, **CSV_ARGS).read
    end

    def tempfile
      @tempfile ||= file&.tempfile
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
