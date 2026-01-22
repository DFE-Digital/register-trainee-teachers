# frozen_string_literal: true

module BulkUpdate
  module AddTrainees
    class EmptyTemplatesController < ApplicationController
      skip_before_action :authenticate

      FILE = "bulk_create_trainee.csv"

      def show
        respond_to do |format|
          format.csv do
            send_file(
              Rails.public_path.join("csv/#{version}/#{FILE}"),
              filename: filename,
              disposition: :attachment,
            )
          end
        end
      end

    private

      def version
        BulkUpdate::BulkAddTraineesUploadForm::VERSION.tr(".", "_")
      end

      def filename
        "#{version}_#{FILE}"
      end
    end
  end
end
