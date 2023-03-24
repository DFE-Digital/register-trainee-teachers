# frozen_string_literal: true

require "rails_helper"

RSpec.describe BulkUpdate::RecommendationsUpload do
  describe "associations" do
    it { is_expected.to have_many(:recommendations_upload_rows) }
    it { is_expected.to belong_to(:provider) }
    it { is_expected.to have_one_attached(:file) }
  end

  describe "instance methods" do
    let(:recommendations_upload) { create(:bulk_update_recommendations_upload) }
    let(:complete_row) { create(:bulk_update_recommendations_upload_row) }
    let(:error_row) { create(:bulk_update_recommendations_upload_row, :with_error) }
    let(:missing_date_row) { create(:bulk_update_recommendations_upload_row, :missing_date) }
    let(:missing_date_and_error_row) { create(:bulk_update_recommendations_upload_row, :missing_date, :with_error) }

    before do
      recommendations_upload.recommendations_upload_rows = [complete_row, error_row, missing_date_row, missing_date_and_error_row]
    end

    describe "awardable_rows" do
      it "returns the rows with dates and no errors" do
        expect(recommendations_upload.awardable_rows).to match_array([complete_row])
      end
    end

    describe "missing_date_rows" do
      it "returns the rows with missing dates and no errors" do
        expect(recommendations_upload.missing_date_rows).to match_array([missing_date_row])
      end
    end

    describe "error_rows" do
      context "with rows with single error"
      it "returns the rows with errors" do
        expect(recommendations_upload.error_rows).to match_array([error_row, missing_date_and_error_row])
      end
    end

    context "with a row with multiple errors" do
      let(:multiple_errors_row) do
        create(
          :bulk_update_recommendations_upload_row,
          :with_multiple_errors,
          recommendations_upload:,
        )
      end

      it "returns the rows with errors" do
        expect(recommendations_upload.error_rows).to match_array([error_row, multiple_errors_row, missing_date_and_error_row])
      end
    end
  end
end
