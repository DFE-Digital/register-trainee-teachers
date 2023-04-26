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
      before do
        allow(RecommendationsUploads::ValidateCsv).to receive(:new).with(anything).and_return(double("validation", validate!: true))
        allow(RecommendationsUploads::ValidateFile).to receive(:new).with(anything).and_return(double("validation", validate!: true))
      end

      context "that is a CSV with expected headers" do
        let(:test_file) { file_fixture("bulk_update/recommendations_upload/complete.csv") }

        it "returns a RecommendationsUpload record and CSV::Table" do
          expect(form.valid?).to be true
          form.save
          expect(form.recommendations_upload).to be_a BulkUpdate::RecommendationsUpload
          expect(form.csv).to be_a CSV::Table
        end
      end

      context "that has possibly malicious scripts" do
        let(:test_file) { file_fixture("bulk_update/recommendations_upload/injected.csv") }

        it "returns a RecommendationsUpload record and sanitised CSV::Table" do
          # cell containing potential spreadsheet formula is safely quoted to avoid execution
          expect(form.csv["lead school"][-1][0]).to eql "'"
          expect(form.valid?).to be true
          form.save
          expect(form.recommendations_upload).to be_a BulkUpdate::RecommendationsUpload
          expect(form.csv).to be_a CSV::Table
        end
      end
    end
  end
end
