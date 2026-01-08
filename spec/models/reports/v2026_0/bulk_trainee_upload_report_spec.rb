# frozen_string_literal: true

require "rails_helper"

describe Reports::BulkTraineeUploadReport do
  before do
    stub_const("BulkUpdate::AddTrainees::Config::VERSION", "v2026.0")
    stub_const("BulkUpdate::AddTrainees::VERSION", BulkUpdate::AddTrainees::V20260)
  end

  context "given an empty trainee upload" do
    let(:trainee_upload) { create(:bulk_update_trainee_upload) }

    it "generates a CSV with the correct headers and no rows" do
      generated_csv = CSV.generate(quote_char: '"', force_quotes: true) do |csv|
        described_class.new(csv, scope: trainee_upload).generate_report
      end

      data = CSV.parse(generated_csv)
      expect(data.size).to eq(1)
      expect(data[0]).to eq(BulkUpdate::AddTrainees::V20260::ImportRows::ALL_HEADERS.keys + ["Validation results", "Errors"])
    end
  end

  context "given a valid trainee upload without errors" do
    let(:trainee_upload) { create(:bulk_update_trainee_upload, :with_rows) }
    let(:original_csv_data) { CSV.parse(trainee_upload.file.download, headers: true) }

    it "generates a CSV with 'Validation results' and 'Errors' column" do
      generated_csv = CSV.generate do |csv|
        described_class.new(csv, scope: trainee_upload).generate_report
      end

      data = CSV.parse(generated_csv, headers: true)

      expect(data.size).to eq(5)

      data.each_with_index do |row, index|
        expect(row.fetch("Validation results")).to eq("Validation passed")
        expect(row.fetch("Errors")).to be_blank
        expect(row.to_h.except("Validation results", "Errors")).to eq(original_csv_data[index].to_h)
      end
    end
  end

  context "given a valid trainee upload with some errors" do
    let(:trainee_upload) { create(:bulk_update_trainee_upload, :failed_with_validation_errors) }

    it "generates a CSV with 'Validation results' and 'Errors' column" do
      generated_csv = CSV.generate do |csv|
        described_class.new(csv, scope: trainee_upload).generate_report
      end

      data = CSV.parse(generated_csv, headers: true)
      expect(data.size).to eq(5)

      expect(data[0].fetch("Validation results")).to eq("Validation passed")
      expect(data[0].fetch("Errors")).to be_blank

      expect(data[1].fetch("Validation results")).to eq("Validation passed")
      expect(data[1].fetch("Errors")).to be_blank

      expect(data[2].fetch("Validation results")).to eq("Validation passed")
      expect(data[2].fetch("Errors")).to be_blank

      expect(data[3].fetch("Validation results")).to eq("1 error found")
      expect(data[3].fetch("Errors")).to eq(
        trainee_upload.trainee_upload_rows[3].row_errors.pluck(:message).join(";"),
      )

      expect(data[4].fetch("Validation results")).to eq("2 errors found")
      expect(data[4].fetch("Errors")).to eq(
        trainee_upload.trainee_upload_rows[4].row_errors.pluck(:message).join(";\n"),
      )
    end
  end
end
