# frozen_string_literal: true

module BulkUpdate
  module AddTrainees
    class EmptyTemplatesController < CsvDocs::BaseController
      FILE = "bulk_create_trainee.csv"

      def show
        respond_to do |format|
          format.csv do
            send_file(
              Rails.public_path.join("csv/#{FILE}"),
              filename: filename,
              disposition: :attachment,
            )
          end
        end
      end

    private

      def filename
        "#{BulkUpdate::BulkAddTraineesUploadForm::VERSION.tr('.', '_')}_#{FILE}"
      end
    end
  end
end
