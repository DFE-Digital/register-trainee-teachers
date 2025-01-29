# frozen_string_literal: true

module BulkUpdate
  module Imports
    class TraineeUploadPolicy < TraineeUploads::BasePolicy
      def create?
        user.hei_provider? && trainee_upload.uploaded?
      end
    end
  end
end
