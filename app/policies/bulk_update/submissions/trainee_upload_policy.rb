# frozen_string_literal: true

module BulkUpdate
  module Submissions
    class TraineeUploadPolicy < BulkUpdate::TraineeUploadPolicy
      def show?
        super && (trainee_upload.in_progress? || trainee_upload.succeeded? || trainee_upload.failed?)
      end

      def create?
        super && (trainee_upload.validated? || trainee_upload.failed?)
      end
    end
  end
end
