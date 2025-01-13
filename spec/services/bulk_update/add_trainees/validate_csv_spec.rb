# frozen_string_literal: true

require "rails_helper"

module BulkUpdate
  module AddTrainees
    describe ValidateCsv do
      subject(:service) { described_class.new(csv:, record:) }

      let(:record) { ::BulkUpdate::BulkAddTraineesUploadForm.new }

      before do
        service.validate!
      end

      context "given a CSV with missing columns" do
        let(:file_path) { Rails.root.join("spec/fixtures/files/bulk_update/trainee_uploads/five_trainees_with_missing_column.csv") }
        let(:csv) do
          CSVSafe.new(
            File.open(file_path),
            headers: true,
          ).read
        end

        it { expect(record.errors.first.message).to eql "CSV header must include: #{BulkUpdate::AddTrainees::ImportRows::ALL_HEADERS.keys.join(', ')}" }
      end

      context "given a CSV file with no data (just a header)" do
        let(:file_path) { Rails.root.join("spec/fixtures/files/bulk_update/trainee_uploads/five_trainees_with_missing_column.csv") }
        let(:csv) do
          CSVSafe.new(
            BulkUpdate::AddTrainees::ImportRows::ALL_HEADERS.keys.join(","),
            headers: true,
          ).read
        end

        it { expect(record.errors.first.message).to eql "The selected file must contain at least one trainee" }
      end
    end
  end
end
