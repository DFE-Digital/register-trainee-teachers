# frozen_string_literal: true

module BulkUpdate
  module Submissions
    class TraineeUploadPolicy < BulkUpdate::TraineeUploadPolicy
      def show?
        super && (trainee_upload.submitted? || trainee_upload.succeeded?)
      end

      def create?
        super && trainee_upload.validated?
      end
    end
  end
end
