# frozen_string_literal: true

module BulkUpdate
  module AddTrainees
    class EmptyTemplatesController < CsvDocs::BaseController
      def show
        respond_to do |format|
          format.csv do
            send_file(
              Rails.public_path.join("csv/bulk_create_trainee.csv"),
              disposition: :attachment,
            )
          end
        end
      end
    end
  end
end
