# frozen_string_literal: true

module BulkUpdate
  class BulkAddTraineesUploadForm
    attr_reader :provider, :file, :upload

    include ActiveModel::Model
    include ActiveModel::AttributeAssignment
    include ActiveModel::Validations::Callbacks

    # TODO: Rename this to something more generic?
    include RecommendationsUploads::Config

    validate :validate_file!
    validate :validate_csv!

    def initialize(provider: nil, file: nil)
      @provider = provider
      @file     = file
      @upload   = build_upload
    end

    def save
      return false unless valid?

      upload.file               = file
      upload.number_of_trainees = csv&.count
      upload.save!

      BulkUpdate::AddTrainees::ImportRowsJob.perform_later(id: upload.id)

      upload
    end

    def csv
      return if file.nil? || errors[:file].present?

      file.tempfile.rewind

      @csv ||= CSVSafe.new(file.tempfile, **CSV_ARGS).read
    end

  private

    def build_upload
      BulkUpdate::TraineeUpload.new(
        status: :pending,
        provider:,
      )
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
  end
end
