# frozen_string_literal: true

module BulkUpdate
  module TraineeUploads
    module Show
      module Failed
        class View < BulkUpdate::TraineeUploads::Show::Base::View
          def initialize(upload:, current_user: nil)
            super

            @bulk_add_trainee_upload_form = BulkUpdate::BulkAddTraineesUploadForm.new(
              provider: current_user.organisation,
            )
          end
        end
      end
    end
  end
end
