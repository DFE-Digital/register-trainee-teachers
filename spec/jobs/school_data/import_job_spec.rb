# frozen_string_literal: true

require "rails_helper"

module SchoolData
  describe ImportJob do
    include ActiveJob::TestHelper

    let(:download_record) { create(:school_data_download, :completed) }
    let(:extracted_files) { ["file1.csv", "file2.csv"] }
    let(:import_stats) { { created: 5, updated: 10, errors: [] } }
    let(:successful_scraper_result) do
      double("scraper_result",
             success?: true,
             extracted_files: extracted_files,
             download_record: download_record,
             error_message: nil)
    end
    let(:failed_scraper_result) do
      double("scraper_result",
             success?: false,
             extracted_files: [],
             download_record: download_record,
             error_message: "Download failed")
    end

    before do
      allow(SchoolData::CsvScraper).to receive(:call).and_return(successful_scraper_result)
      allow(SchoolData::ImportService).to receive(:call).and_return(import_stats)
      allow(Rails.logger).to receive(:info)
      allow(Rails.logger).to receive(:error)
    end

    context "when feature flag is disabled" do
      before do
        disable_features("school_data_auto_import")
      end

      it "does not run the import process" do
        described_class.perform_now

        expect(SchoolData::CsvScraper).not_to have_received(:call)
        expect(SchoolData::ImportService).not_to have_received(:call)
      end
    end

    context "when feature flag is enabled" do
      before do
        enable_features("school_data_auto_import")
      end

      describe "successful workflow" do
        it "calls the scraper service" do
          described_class.perform_now

          expect(SchoolData::CsvScraper).to have_received(:call)
        end

        it "calls the import service with correct parameters" do
          described_class.perform_now

          expect(SchoolData::ImportService).to have_received(:call).with(
            csv_files: extracted_files,
            download_record: download_record,
          )
        end

        it "logs success message" do
          described_class.perform_now

          expect(Rails.logger).to have_received(:info).with("Starting school data import job")
          expect(Rails.logger).to have_received(:info).with("School data import job completed successfully")
        end
      end

      describe "scraper failure scenarios" do
        before do
          allow(SchoolData::CsvScraper).to receive(:call).and_return(failed_scraper_result)
        end

        it "handles scraper failure" do
          described_class.perform_now

          expect(SchoolData::ImportService).not_to have_received(:call)
        end

        it "logs scraper failure" do
          described_class.perform_now

          expect(Rails.logger).to have_received(:error).with("School data scraper failed: Download failed")
        end

        context "when scraper returns wrong number of files" do
          let(:successful_scraper_result) do
            double("scraper_result",
                   success?: true,
                   extracted_files: ["only_one_file.csv"],
                   download_record: download_record,
                   error_message: nil)
          end

          before do
            allow(SchoolData::CsvScraper).to receive(:call).and_return(successful_scraper_result)
          end

          it "treats it as a scraper failure" do
            described_class.perform_now

            expect(SchoolData::ImportService).not_to have_received(:call)
          end
        end
      end

      describe "import service failure scenarios" do
        let(:import_error) { StandardError.new("Import service failed") }

        before do
          allow(SchoolData::ImportService).to receive(:call).and_raise(import_error)
        end

        it "handles import failure" do
          expect { described_class.perform_now }.to raise_error(StandardError, "Import service failed")
        end

        it "logs import failure" do
          expect { described_class.perform_now }.to raise_error(StandardError)

          expect(Rails.logger).to have_received(:error).with("School data import job failed: Import service failed")
        end
      end
    end
  end
end
