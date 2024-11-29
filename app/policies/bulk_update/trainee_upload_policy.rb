# frozen_string_literal: true

module BulkUpdate
  class TraineeUploadPolicy < TraineeUploads::BasePolicy
    def new?
      user.hei_provider?
    end

    def create?
      new? && !trainee_upload.cancelled?
    end

    alias_method :show?, :create?
    alias_method :destroy?, :create?
  end
end
