# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolData::ImportJob do
  include ActiveSupport::Testing::TimeHelpers

  subject(:job) { described_class.new }

  let(:csv_content) { "URN,EstablishmentName\n123456,Test School" }
  let(:mock_import_result) { { created: 10, updated: 5, training_partners_updated: 2 } }

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
        allow(SchoolData::SchoolDataDownloader).to receive(:call).and_return(csv_content)
        allow(SchoolData::ImportService).to receive(:call).and_return(mock_import_result)
      end

      it "creates a tracking record with correct attributes" do
        freeze_time do
          expected_attributes = {
            status: :running,
            started_at: Time.current,
          }

          expect(SchoolDataDownload).to receive(:create!).with(expected_attributes)

          job.perform
        end
      end

      it "calls the downloader service" do
        expect(SchoolData::SchoolDataDownloader).to receive(:call)
        job.perform
      end

      it "calls the import service with the CSV content and download record" do
        expect(SchoolData::ImportService).to receive(:call).with(
          csv_content:,
          download_record:,
        )
        job.perform
      end

      it "returns the download record" do
        result = job.perform
        expect(result).to eq(download_record)
      end

      context "when an error occurs" do
        let(:error) { StandardError.new("Something went wrong") }

        before do
          allow(SchoolData::SchoolDataDownloader).to receive(:call).and_raise(error)
        end

        it "updates download record status to failed" do
          expect { job.perform }.to raise_error(error)

          download_record.reload
          expect(download_record.status).to eq("failed")
          expect(download_record.completed_at).to be_present
        end

        it "re-raises the error" do
          expect { job.perform }.to raise_error(error)
        end

        context "when download record is nil" do
          before do
            allow(SchoolDataDownload).to receive(:create!).and_return(nil)
          end

          it "does not crash when trying to update nil download record" do
            expect { job.perform }.to raise_error(error)
          end
        end
      end
    end
  end
end
