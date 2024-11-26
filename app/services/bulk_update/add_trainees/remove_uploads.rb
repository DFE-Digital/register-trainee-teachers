# frozen_string_literal: true

module BulkUpdate
  module AddTrainees
    class RemoveUploads
      include ServicePattern

      def call
        BulkUpdate::TraineeUpload.cancelled.or(
          BulkUpdate::TraineeUpload.failed,
        ).destroy_all
      end
    end
  end
end
