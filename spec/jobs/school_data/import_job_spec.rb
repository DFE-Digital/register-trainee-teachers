# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolData::ImportJob, type: :job do
  subject(:job) { described_class.new }

  let(:mock_downloader_result) { double("downloader_result", filtered_csv_path: "/tmp/filtered_data.csv") }
  let(:mock_import_result) { { created: 10, updated: 5, errors: [], lead_partners_updated: 2 } }

  describe "#perform" do
    context "when feature flag is disabled", feature_school_data_auto_import: false do
      it "exits early without creating any records" do
        expect(SchoolDataDownload).not_to receive(:create!)
        expect(SchoolData::SchoolDataDownloader).not_to receive(:call)
        expect(SchoolData::ImportService).not_to receive(:call)

        expect(job.perform).to be_nil
      end
    end

    context "when feature flag is enabled", feature_school_data_auto_import: true do
      let(:download_record) do
        create(:school_data_download,
               status: :running,
               started_at: Time.current)
      end

      before do
        allow(SchoolDataDownload).to receive(:create!).and_return(download_record)
        allow(SchoolData::SchoolDataDownloader).to receive(:call).and_return(mock_downloader_result)
        allow(SchoolData::ImportService).to receive(:call).and_return(mock_import_result)
      end

      it "creates a tracking record with correct attributes" do
        freeze_time do
          expected_attributes = {
            status: :running,
            started_at: Time.current,
          }

          expect(SchoolDataDownload).to receive(:create!).with(expected_attributes).and_return(download_record)

          job.perform
        end
      end

      it "calls the downloader service with the download record" do
        expect(SchoolData::SchoolDataDownloader).to receive(:call).with(download_record:)
        job.perform
      end

      it "calls the import service with the filtered CSV path and download record" do
        expect(SchoolData::ImportService).to receive(:call).with(
          filtered_csv_path: "/tmp/filtered_data.csv",
          download_record: download_record,
        )
        job.perform
      end

      it "returns the download record" do
        result = job.perform
        expect(result).to eq(download_record)
      end
    end

    context "when an error occurs during download phase", feature_school_data_auto_import: true do
      let(:download_record) { create(:school_data_download, status: :running) }
      let(:error) { StandardError.new("Download failed") }

      before do
        allow(SchoolDataDownload).to receive(:create!).and_return(download_record)
        allow(SchoolData::SchoolDataDownloader).to receive(:call).and_raise(error)
      end

      it "re-raises the error for job retry mechanisms" do
        expect { job.perform }.to raise_error("Download failed")
      end
    end

    context "when an error occurs during import phase", feature_school_data_auto_import: true do
      let(:download_record) { create(:school_data_download, status: :running) }
      let(:error) { StandardError.new("Import failed") }

      before do
        allow(SchoolDataDownload).to receive(:create!).and_return(download_record)
        allow(SchoolData::SchoolDataDownloader).to receive(:call).and_return(mock_downloader_result)
        allow(SchoolData::ImportService).to receive(:call).and_raise(error)
      end

      it "re-raises the error" do
        expect { job.perform }.to raise_error("Import failed")
      end
    end

    context "when download record creation fails", feature_school_data_auto_import: true do
      before do
        allow(SchoolDataDownload).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)
      end

      it "re-raises the error" do
        expect { job.perform }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
