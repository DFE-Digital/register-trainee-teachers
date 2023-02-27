# frozen_string_literal: true

module BulkUpdate
  class RecommendationsUploadForm
    include ActiveModel::Model
    include ActiveModel::AttributeAssignment
    include ActiveModel::Validations::Callbacks

    validate :csv_is_valid?

    def initialize(provider: nil, file: nil)
      @provider = provider
      @file = file
    end

    def save
      return false unless valid?

      @recommendations_upload = RecommendationsUpload.create(provider:, file:)
    end

    def csv
      @csv ||= CSV.new(file.tempfile, headers: true).read
    end

    attr_reader :recommendations_upload

  private

    attr_reader :provider, :file

    def csv_is_valid?
      return true if Recommend::ValidateCsv.new(csv).valid?

      errors.add(:file, "CSV not valid")
    rescue CSV::MalformedCSVError
      errors.add(:file, "File must be a CSV")
    end
  end
end
