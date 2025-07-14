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
      allow(SlackNotifierService).to receive(:call)
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
        expect(SlackNotifierService).not_to have_received(:call)
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

        it "sends success notification" do
          described_class.perform_now

          expect(SlackNotifierService).to have_received(:call).with(
            message: include("School data import completed successfully!"),
            username: "School Data Import Bot",
            icon_emoji: ":school:",
          )
        end

        it "logs success message" do
          described_class.perform_now

          expect(Rails.logger).to have_received(:info).with("Starting school data import job")
          expect(Rails.logger).to have_received(:info).with("School data import job completed successfully")
        end

        context "with import errors" do
          let(:import_stats) do
            {
              created: 5,
              updated: 10,
              errors: [
                { urn: "123456", error: "Invalid data" },
                { urn: "789012", error: "Missing field" },
              ],
            }
          end

          it "includes error details in success notification" do
            described_class.perform_now

            expect(SlackNotifierService).to have_received(:call).with(
              message: include("Errors: 2") && include("URN 123456: Invalid data"),
              username: "School Data Import Bot",
              icon_emoji: ":school:",
            )
          end
        end

        context "with many import errors" do
          let(:import_stats) do
            {
              created: 5,
              updated: 10,
              errors: (1..10).map { |i| { urn: "#{i}23456", error: "Error #{i}" } },
            }
          end

          it "limits error display and shows count" do
            described_class.perform_now

            expect(SlackNotifierService).to have_received(:call).with(
              message: include("and 5 more errors"),
              username: "School Data Import Bot",
              icon_emoji: ":school:",
            )
          end
        end
      end

      describe "scraper failure scenarios" do
        before do
          allow(SchoolData::CsvScraper).to receive(:call).and_return(failed_scraper_result)
        end

        it "handles scraper failure and sends notification" do
          described_class.perform_now

          expect(SchoolData::ImportService).not_to have_received(:call)
          expect(SlackNotifierService).to have_received(:call).with(
            message: include("School data scraper failed!") && include("Download failed"),
            username: "School Data Import Bot",
            icon_emoji: ":exclamation:",
          )
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
            expect(SlackNotifierService).to have_received(:call).with(
              message: include("School data scraper failed!"),
              username: "School Data Import Bot",
              icon_emoji: ":exclamation:",
            )
          end
        end
      end

      describe "import service failure scenarios" do
        let(:import_error) { StandardError.new("Import service failed") }

        before do
          allow(SchoolData::ImportService).to receive(:call).and_raise(import_error)
        end

        it "handles import failure and sends notification" do
          expect { described_class.perform_now }.to raise_error(StandardError, "Import service failed")

          expect(SlackNotifierService).to have_received(:call).with(
            message: include("School data import job failed!") && include("Import service failed"),
            username: "School Data Import Bot",
            icon_emoji: ":fire:",
          )
        end

        it "logs import failure" do
          expect { described_class.perform_now }.to raise_error(StandardError)

          expect(Rails.logger).to have_received(:error).with("School data import job failed: Import service failed")
        end
      end

      describe "message formatting" do
        let(:download_record) do
          create(:school_data_download, :completed,
                 started_at: 1.hour.ago,
                 completed_at: Time.current,
                 file_count: 2)
        end

        it "formats duration correctly" do
          described_class.perform_now

          expect(SlackNotifierService).to have_received(:call).with(
            message: include("Duration: 60.0 minutes"),
            username: "School Data Import Bot",
            icon_emoji: ":school:",
          )
        end

        it "includes all summary statistics" do
          described_class.perform_now

          expect(SlackNotifierService).to have_received(:call).with(
            message: include("Schools created: 5") &&
                    include("Schools updated: 10") &&
                    include("Files processed: 2"),
            username: "School Data Import Bot",
            icon_emoji: ":school:",
          )
        end
      end
    end
  end
end
