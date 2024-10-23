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
      return false unless valid?

      BulkUpdate::AddTrainees::ImportRowsJob.perform_later(id: upload.id)

      upload
    end
  end
end
