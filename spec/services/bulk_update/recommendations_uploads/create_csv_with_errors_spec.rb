# frozen_string_literal: true

require "rails_helper"

module BulkUpdate
  module RecommendationsUploads
    describe CreateCsvWithErrors do
      let!(:recommendations_upload) { create(:bulk_update_recommendations_upload) }
      let!(:recommendations_upload_row) do
        create(
          :bulk_update_recommendations_upload_row,
          :with_error,
          csv_row_number: 3,
          recommendations_upload: recommendations_upload,
        )
      end

      subject { described_class.call(recommendations_upload:) }

      describe "#call" do
        it "adds an error column with the errors" do
          expect(subject[1]["Errors"]).to eq("An error has occured")
        end

        it "adds 'Do not edit' to the first row" do
          expect(subject[0]["Errors"]).to eq("Do not edit")
        end
      end
    end
  end
end
