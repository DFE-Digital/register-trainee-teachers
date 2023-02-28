# frozen_string_literal: true

require "rails_helper"

module BulkUpdate
  describe RecommendationsUploadForm, type: :model do
    subject(:form) { described_class.new(provider:, file:) }

    let(:provider) { create(:provider) }
    let(:file) do
      ActionDispatch::Http::UploadedFile.new(
        {
          filename: "test.csv",
          tempfile: tempfile,
          type: content_type,
        },
      )
    end

    let(:tempfile) do
      t = Tempfile.new("test.csv")
      t.write(test_file.read)
      t.rewind
      t
    end

    let(:content_type) { "text/csv" }

    context "when passed a file" do
      context "that is a CSV with expected headers" do
        let(:test_file) { file_fixture("bulk_update/recommendations_upload/complete.csv") }

        it "returns an a RecommendationsUpload record and CSV::Table" do
          expect(form.valid?).to be true
          form.save
          expect(form.recommendations_upload).to be_a BulkUpdate::RecommendationsUpload
          expect(form.csv).to be_a CSV::Table
        end
      end

      context "that is not a CSV" do
        let(:test_file) { file_fixture("bulk_update/recommendations_upload/not_a_csv.csv") }

        it "is invalid" do
          expect(form.valid?).to be false
          expect(form.errors.full_messages.first).to eql "File File must be a CSV"
        end
      end

      context "that is a CSV with missing headers" do
        let(:test_file) { file_fixture("bulk_update/recommendations_upload/missing_required_header.csv") }

        it "is invalid" do
          expect(form.valid?).to be false
          expect(form.errors.full_messages.first).to eql "File CSV not valid"
        end
      end
    end
  end
end
