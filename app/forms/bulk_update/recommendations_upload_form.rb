# frozen_string_literal: true

module BulkUpdate
  class RecommendationsUploadForm
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

      @recommendations_upload = RecommendationsUpload.create(provider:, file:)
    end

    def csv
      @csv ||= CSV.new(file.tempfile, headers: true, header_converters: :downcase, strip: true).read
    end

    attr_reader :recommendations_upload, :provider, :file

  private

    def tempfile
      @tempfile ||= file&.tempfile
    end

    def validate_file!
      RecommendationsUploads::ValidateFile.new(file: file, record: self).validate!
    end

    def validate_csv!
      return unless tempfile

      RecommendationsUploads::ValidateCsv.new(csv: csv, record: self).validate!
    rescue CSV::MalformedCSVError
      errors.add(:file, "File must be a CSV")
    end
  end
end
