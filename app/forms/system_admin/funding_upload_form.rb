# frozen_string_literal: true

module SystemAdmin
  class FundingUploadForm
    include ActiveModel::Model

    attr_accessor :funding_type, :month, :file
    attr_reader :funding_upload

    validates :funding_type, presence: true
    validates :month, presence: true
    validates :file, presence: true

    def save!
      return false unless valid?

      @funding_upload = FundingUpload.create!(
        funding_type:,
        month:,
        csv_data: file.read,
      )
    end
  end
end
