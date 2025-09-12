# frozen_string_literal: true

module BulkUpdate
  class TraineeUploadPolicy < TraineeUploads::BasePolicy
    def new?
      user.accredited_hei_provider?
    end

    def create?
      new? && !trainee_upload.cancelled?
    end

    alias_method :show?, :create?
    alias_method :destroy?, :create?
    alias_method :index?, :new?
  end
end
