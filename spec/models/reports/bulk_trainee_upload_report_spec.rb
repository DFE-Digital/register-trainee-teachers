# frozen_string_literal: true

require "rails_helper"

describe Reports::BulkTraineeUploadReport do
  context "given an empty trainee upload" do
    let(:trainee_upload) { create(:bulk_update_trainee_upload) }

    it "generates a CSV with the correct headers and no rows" do
      generated_csv = CSV.generate do |csv|
        described_class.new(csv, scope: trainee_upload).generate_report
      end

      data = CSV.parse(generated_csv)
      expect(data.size).to eq(1)
      expect(data[0]).to eq(BulkUpdate::AddTrainees::ImportRows::ALL_HEADERS.keys + ["Errors"])
    end
  end

  context "given a valid trainee upload without errors" do
    let(:trainee_upload) { create(:bulk_update_trainee_upload, :with_rows) }
    let(:original_csv_data) { CSV.parse(trainee_upload.file.download, headers: true) }

    it "generates a CSV with an extra _Errors_ column with empty values" do
      generated_csv = CSV.generate do |csv|
        described_class.new(csv, scope: trainee_upload).generate_report
      end

      data = CSV.parse(generated_csv, headers: true)
      expect(data.size).to eq(5)
      data.each_with_index do |row, index|
        expect(row.key?("Errors")).to be(true)
        expect(row["Errors"]).to be_blank
        expect(row.to_h.except("Errors")).to eq(original_csv_data[index].to_h)
      end
    end
  end

  context "given a valid trainee upload with some errors" do
    let(:trainee_upload) { create(:bulk_update_trainee_upload, :failed_with_validation_errors) }

    it "generates a CSV with an extra _Errors_ column" do
      generated_csv = CSV.generate do |csv|
        described_class.new(csv, scope: trainee_upload).generate_report
      end

      data = CSV.parse(generated_csv, headers: true)
      expect(data.size).to eq(5)
      expect(data[0]["Errors"]).to be_blank
      expect(data[1]["Errors"]).to be_blank
      expect(data[2]["Errors"]).to be_blank
      expect(data[3]["Errors"]).to be_present
      expect(data[3]["Errors"]).to eq(
        trainee_upload.trainee_upload_rows[3].row_errors.pluck(:message).join(", "),
      )
      expect(data[4]["Errors"]).to be_present
      expect(data[4]["Errors"]).to eq(
        trainee_upload.trainee_upload_rows[4].row_errors.pluck(:message).join(", "),
      )
    end
  end
end
