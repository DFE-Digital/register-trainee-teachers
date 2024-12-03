# frozen_string_literal: true

module BulkUpdate
  module Details
    class TraineeUploadPolicy < BulkUpdate::TraineeUploads::BasePolicy
      def show?
        user.hei_provider? && trainee_upload.succeeded?
      end
    end
  end
end
