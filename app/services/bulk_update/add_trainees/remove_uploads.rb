# frozen_string_literal: true

module BulkUpdate
  module AddTrainees
    class RemoveUploads
      include ServicePattern

      def call
        BulkUpdate::TraineeUpload.cancelled.or(
          BulkUpdate::TraineeUpload.failed,
        ).or(
          BulkUpdate::TraineeUpload.uploaded,
        ).includes(:row_errors).destroy_all
      end
    end
  end
end
