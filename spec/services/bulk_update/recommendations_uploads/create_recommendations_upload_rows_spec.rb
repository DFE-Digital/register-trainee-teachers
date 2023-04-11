# frozen_string_literal: true

require "rails_helper"

module BulkUpdate
  module RecommendationsUploads
    describe CreateRecommendationsUploadRows do
      subject(:service) { described_class.call(recommendations_upload:, csv:) }

      let(:csv) { CSV.new(file.read, headers: true, header_converters: :downcase, strip: true).read }
      let(:recommendations_upload) { create(:bulk_update_recommendations_upload) }
      let(:provider) { recommendations_upload.provider }

      before { service }

      describe "#call" do
        context "given a valid CSV" do
          let(:file) { file_fixture("bulk_update/recommendations_upload/complete.csv") }

          it "creates the rows with the correct row numbers" do
            expect(provider.recommendations_upload_rows.pluck(:trn, :csv_row_number, :standards_met_at)).to eql(
              [
                ["2413295", 3, "20-07-2022".to_date],
                ["4814731", 4, "21-07-2022".to_date],
              ],
            )
          end
        end

        context "given an valid CSV with errorable rows" do
          let(:file) { file_fixture("bulk_update/recommendations_upload/with_invalid_trn.csv") }

          it "creates the row records and error records" do
            expect(provider.recommendations_upload_rows.pluck(:trn, :csv_row_number, :standards_met_at)).to eql(
              [
                ["241a295", 3, "20-07-2022".to_date],
                ["4814731", 4, "21-07-2022".to_date],
              ],
            )

            row_errors = RecommendationsUploadRow.find_by(trn: "241a295").row_errors
            expect(row_errors.first.message).to eql "TRN must be 7 numbers"
          end
        end

        context "given a CSV with no 'Do not edit' row" do
          let(:file) { file_fixture("bulk_update/recommendations_upload/missing_do_not_edit_row.csv") }

          it "creates the rows with the correct row numbers" do
            expect(provider.recommendations_upload_rows.pluck(:trn, :csv_row_number, :standards_met_at)).to eql(
              [
                ["2413295", 2, "20-07-2022".to_date],
                ["4814731", 3, "21-07-2022".to_date],
              ],
            )
          end
        end
      end
    end
  end
end
