# frozen_string_literal: true

module BulkUpdate
  class BulkAddTraineesSubmitForm
    attr_reader :provider, :upload

    include ActiveModel::Model
    include ActiveModel::AttributeAssignment
    include ActiveModel::Validations::Callbacks

    def initialize(upload:)
      @upload = upload
    end

    def save
      return false unless valid? && upload.validated?

      upload.in_progress!

      BulkUpdate::AddTrainees::ImportRowsJob.perform_later(upload)
    end
  end
end
