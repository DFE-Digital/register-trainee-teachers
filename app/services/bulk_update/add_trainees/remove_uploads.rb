# frozen_string_literal: true

module BulkUpdate
  module AddTrainees
    class RemoveUploads
      include ServicePattern

      def call
        TraineeUpload.cancelled.or(
          TraineeUpload.failed
        ).destroy_all
      end
    end
  end
end
