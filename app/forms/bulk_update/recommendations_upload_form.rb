# frozen_string_literal: true

module BulkUpdate
  class RecommendationsUploadForm
    include ActiveModel::Model
    include ActiveModel::AttributeAssignment
    include ActiveModel::Validations::Callbacks

    validate :csv_is_valid?

    def initialize(current_user: nil, file: nil)
      @current_user = current_user
      @file = file
    end

    def save
      return false unless valid?

      @recommendations_upload = RecommendationsUpload.create(user: current_user, file: file)
    end

    def csv
      @csv ||= CSV.new(file.tempfile, headers: true).read
    end

    attr_reader :recommendations_upload

  private

    attr_reader :current_user, :file

    def csv_is_valid?
      return true if Recommend::ValidateCsv.new(csv).valid?

      errors.add(:file, "CSV not valid")
    rescue CSV::MalformedCSVError
      errors.add(:file, "File must be a CSV")
    end
  end
end
