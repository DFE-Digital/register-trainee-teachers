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
      @file = file
    end

    def save
      return false unless valid?

      upload = BulkUpdate::TraineeUpload.create(
        provider: provider,
        file: File.read(file),
        file_name: file.original_filename,
        number_of_trainees: csv&.count,
        status: valid? ? :pending : :failed,
        error_messages: errors.messages.values.inject([], &:concat),
      )

      BulkUpdate::AddTrainees::ImportRowsJob.perform_later(upload)

      upload
    end

    def csv
      file.tempfile.rewind
      @csv ||= file ? CSVSafe.new(file.tempfile, **CSV_ARGS).read : nil
    rescue StandardError
      @csv = nil
    end

  private

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
