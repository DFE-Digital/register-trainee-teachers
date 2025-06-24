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
        let(:csv) { CSVSafe.new(File.open(file_path), headers: true).read }

        it { expect(record.errors.first&.message).to eq("Your file’s column names need to match the CSV template. Your file is missing the following columns: 'HESA ID' and 'Sex'") }
      end

      context "given a CSV with the correct columns in the 'wrong' order" do
        let(:file_content) do
          "#{BulkUpdate::AddTrainees::ImportRows::ALL_HEADERS.keys.reverse.join(',')}\nfoo,bar,baz"
        end
        let(:csv) { CSVSafe.new(file_content, headers: true).read }

        it { expect(record.errors).to be_empty }
      end

      context "given a CSV with the correct columns except one that is an empty string" do
        let(:file_content) do
          "#{BulkUpdate::AddTrainees::ImportRows::ALL_HEADERS.keys.join(',').gsub('First Names', '')}\nfoo,bar,baz"
        end
        let(:csv) { CSVSafe.new(file_content, headers: true).read }

        it { expect(record.errors.first.message).to eq("Your file’s column names need to match the CSV template. Your file is missing the following columns: 'First Names'") }
      end

      context "given a CSV with the correct columns and one extra column" do
        let(:file_content) do
          "#{(BulkUpdate::AddTrainees::ImportRows::ALL_HEADERS.keys + ['Shoe Size']).join(',')}\nfoo,bar,baz"
        end
        let(:csv) { CSVSafe.new(file_content, headers: true).read }

        it { expect(record.errors.first.message).to eq("Your file’s column names need to match the CSV template. Your file has the following extra columns: 'Shoe Size'") }
      end

      context "given a CSV with the correct columns with validation results and errors" do
        let(:file_content) do
          "#{BulkUpdate::AddTrainees::ImportRows::ALL_HEADERS.keys.reverse.join(',')},Validation results,Errors\nfoo,bar,baz"
        end
        let(:csv) { CSVSafe.new(file_content, headers: true).read }

        it { expect(record.errors).to be_empty }
      end

      context "given a CSV file with no data (just a header)" do
        let(:csv) do
          CSVSafe.new(
            BulkUpdate::AddTrainees::ImportRows::ALL_HEADERS.keys.join(","),
            headers: true,
          ).read
        end

        it { expect(record.errors.first&.message).to eq("The selected file must contain at least one trainee") }
      end

      context "given a CSV file with no data (just a header and some empty lines)" do
        let(:csv) do
          CSVSafe.new(
            "#{BulkUpdate::AddTrainees::ImportRows::ALL_HEADERS.keys.join(',')}\n\n\n",
            headers: true,
          ).read
        end

        it { expect(record.errors.first&.message).to eq("The selected file must contain at least one trainee") }
      end
    end
  end
end
