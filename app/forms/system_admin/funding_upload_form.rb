# frozen_string_literal: true

module SystemAdmin
  class FundingUploadForm
    include ActiveModel::Model

    attr_accessor :funding_type, :month, :file

    validates :funding_type, presence: true
    validates :month, presence: true
    validates :file, presence: true
  end
end
