# frozen_string_literal: true

module BulkUpdate
  class BulkAddTraineesImportRowsForm
    include ActiveModel::Model

    attr_reader :upload

    def initialize(upload:)
      @upload = upload
    end

    def save
      upload.import!

      BulkUpdate::AddTrainees::ImportRowsJob.perform_later(upload)

      true
    end
  end
end
