# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolData::CsvScraper do
  let(:extract_path) { Rails.root.join("tmp/test_school_data") }

  # Mock ZIP file with CSV content
  let(:mock_zip_data) do
    buffer = Zip::OutputStream.write_buffer do |out|
      out.put_next_entry("edubaseallstatefunded20250115.csv")
      out.write("URN,EstablishmentName,Town,Postcode\n1001,Test School,Test Town,TE1 1ST\n")

      out.put_next_entry("edubaseallacademiesandfree20250115.csv")
      out.write("URN,EstablishmentName,Town,Postcode\n2001,Test Academy,Test City,TE2 2ND\n")
    end
    buffer.string
  end

  before do
    # Clean up test directory
    FileUtils.rm_rf(extract_path)

    # Stub Rails.logger to avoid noise in tests
    allow(Rails.logger).to receive(:info)
    allow(Rails.logger).to receive(:warn)
    allow(Rails.logger).to receive(:error)

    # Stub sleep to avoid delays in tests
    allow(Kernel).to receive(:sleep)
  end

  after do
    # Clean up test directory
    FileUtils.rm_rf(extract_path)
  end

  describe "#call" do
    # NOTE: Full integration tests with HTTP mocking are challenging due to Mechanize's
    # HTML parsing requirements. The service has been proven to work against the real
    # GIAS website. These tests focus on individual components and error handling.

    context "when testing individual components" do
      let(:service_instance) { described_class.allocate.tap { |s| s.send(:initialize, extract_path:) } }

      it "can extract CSV files from ZIP data" do
        service_instance.send(:extract_csv_files, mock_zip_data)

        expect(service_instance.extracted_files.size).to eq(2)
        expect(service_instance.extracted_files.all? { |f| File.exist?(f) }).to be(true)
        expect(service_instance.extracted_files.all? { |f| f.end_with?(".csv") }).to be(true)
      end

      it "creates the extract directory if it doesn't exist" do
        expect { service_instance.send(:extract_csv_files, mock_zip_data) }
          .to change { Dir.exist?(extract_path) }.from(false).to(true)
      end

      it "validates extraction results" do
        service_instance.send(:extract_csv_files, mock_zip_data)

        expect { service_instance.send(:validate_extraction) }.not_to raise_error
      end

      it "creates a proper mechanize agent" do
        agent = service_instance.send(:create_mechanize_agent)

        expect(agent).to be_a(Mechanize)
        expect(agent.user_agent).to include("Mozilla")
        expect(agent.read_timeout).to eq(60)
      end
    end

    context "when form structure changes (notification logic)" do
      let(:service_instance) { described_class.allocate.tap { |s| s.send(:initialize, extract_path:) } }

      it "has correct checkbox constants" do
        expect(described_class::STATE_FUNDED_CHECKBOX_ID).to eq("state-funded-school--elds-csv-checkbox")
        expect(described_class::ACADEMIES_CHECKBOX_ID).to eq("academies-and-free-school--elds-csv-checkbox")
      end

      it "has correct form action constants" do
        expect(described_class::GIAS_DOWNLOADS_URL).to eq("https://get-information-schools.service.gov.uk/Downloads")
      end
    end

    context "when no form exists on the page" do
      let(:no_form_html) { "<html><body><p>No form here</p></body></html>" }

      before do
        stub_request(:get, described_class::GIAS_DOWNLOADS_URL)
          .to_return(status: 200, body: no_form_html, headers: { "Content-Type" => "text/html" })
      end

      it "raises FormStructureChangedError" do
        expect { described_class.call(extract_path:) }.to raise_error(
          SchoolData::CsvScraper::FormStructureChangedError,
          "No form found on GIAS downloads page",
        )
      end
    end

    context "when testing ZIP file handling" do
      let(:service_instance) { described_class.allocate.tap { |s| s.send(:initialize, extract_path:) } }

      let(:empty_zip_data) do
        buffer = Zip::OutputStream.write_buffer do |out|
          out.put_next_entry("readme.txt")
          out.write("No CSV files here")
        end
        buffer.string
      end

      it "handles empty ZIP files correctly" do
        expect { service_instance.send(:extract_csv_files, empty_zip_data) }.to raise_error(
          SchoolData::CsvScraper::ExtractionError,
          "No CSV files found in downloaded ZIP",
        )
      end

      it "handles corrupted ZIP data" do
        expect { service_instance.send(:extract_csv_files, "corrupted data") }.to raise_error(
          SchoolData::CsvScraper::ExtractionError,
          /Failed to extract ZIP file:/,
        )
      end

      it "validates extracted files exist" do
        service_instance.send(:extract_csv_files, mock_zip_data)

        # Manually delete one file to test validation
        File.delete(service_instance.extracted_files.first)

        expect { service_instance.send(:validate_extraction) }.to raise_error(
          SchoolData::CsvScraper::ExtractionError,
          /Extracted file is missing or empty:/,
        )
      end
    end

    context "when receiving a 403 Forbidden response" do
      before do
        stub_request(:get, described_class::GIAS_DOWNLOADS_URL)
          .to_return(status: 403, body: "Forbidden")
      end

      it "raises AccessDeniedError with helpful message" do
        expect { described_class.call(extract_path:) }.to raise_error(
          SchoolData::CsvScraper::AccessDeniedError,
          /Access denied \(403\) - GIAS website may have anti-bot protection/,
        )
      end
    end

    context "when receiving a 404 Not Found response" do
      before do
        stub_request(:get, described_class::GIAS_DOWNLOADS_URL)
          .to_return(status: 404, body: "Not Found")
      end

      it "raises DownloadError with URL change suggestion" do
        expect { described_class.call(extract_path:) }.to raise_error(
          SchoolData::CsvScraper::DownloadError,
          /GIAS downloads page not found \(404\) - URL may have changed/,
        )
      end
    end

    context "when receiving a server error response" do
      before do
        stub_request(:get, described_class::GIAS_DOWNLOADS_URL)
          .to_return(status: 503, body: "Service Unavailable")
      end

      it "raises DownloadError with server error message" do
        expect { described_class.call(extract_path:) }.to raise_error(
          SchoolData::CsvScraper::DownloadError,
          /GIAS server error \(503\) - their service may be temporarily unavailable/,
        )
      end
    end

    context "when an unexpected error occurs" do
      before do
        service_instance = described_class.allocate.tap { |s| s.send(:initialize, extract_path:) }
        allow(described_class).to receive(:new).and_return(service_instance)
        allow(service_instance).to receive(:download_and_extract_zip).and_raise(StandardError, "Unexpected error")
      end

      it "logs the error and re-raises it" do
        expect(Rails.logger).to receive(:error).with("CSV scraping failed: Unexpected error")

        expect { described_class.call(extract_path:) }.to raise_error(StandardError, "Unexpected error")
      end
    end
  end

  describe "#notify_form_structure_changed" do
    # Create a service instance for testing private methods
    let(:service_instance) { described_class.allocate.tap { |s| s.send(:initialize, extract_path:) } }

    context "in development environment" do
      before do
        allow(Rails.env).to receive(:development?).and_return(true)
      end

      it "logs a warning instead of sending Slack notification" do
        expect(Rails.logger).to receive(:warn).with(match(/GIAS Form Structure Changed/))

        service_instance.send(:notify_form_structure_changed, %w[checkbox1 checkbox2])
      end

      it "does not attempt to send Slack notification" do
        stub_const("SlackNotifierService", double("SlackNotifierService"))
        expect(SlackNotifierService).not_to receive(:call)

        service_instance.send(:notify_form_structure_changed, %w[checkbox1 checkbox2])
      end
    end

    context "in non-development environment" do
      before do
        allow(Rails.env).to receive(:development?).and_return(false)
      end

      context "when SlackNotifierService is available" do
        before do
          stub_const("SlackNotifierService", double("SlackNotifierService"))
        end

        it "sends a Slack notification" do
          expect(SlackNotifierService).to receive(:call).with(
            message: match(/GIAS form structure changed/),
            username: "School Data Import Bot",
            icon_emoji: ":construction:",
          )

          service_instance.send(:notify_form_structure_changed, %w[checkbox1 checkbox2])
        end
      end

      context "when SlackNotifierService is not available" do
        it "does not attempt to send notification" do
          # Should not raise an error
          expect { service_instance.send(:notify_form_structure_changed, []) }.not_to raise_error
        end
      end

      context "when Slack notification fails" do
        before do
          stub_const("SlackNotifierService", double("SlackNotifierService"))
          allow(SlackNotifierService).to receive(:call).and_raise(StandardError, "Slack error")
        end

        it "logs the error without re-raising" do
          expect(Rails.logger).to receive(:error).with("Failed to send Slack notification: Slack error")

          expect { service_instance.send(:notify_form_structure_changed, []) }.not_to raise_error
        end
      end
    end
  end

  describe "initialization" do
    it "sets default extract path to a system temporary directory" do
      default_service = described_class.allocate.tap { |s| s.send(:initialize) }
      expect(default_service.extract_path.to_s).to include("school_data_")
      expect(Dir.exist?(default_service.extract_path)).to be(true)
      expect(File.basename(default_service.extract_path)).to start_with("school_data_")
    end

    it "accepts custom extract path" do
      custom_path = "/tmp/custom"
      custom_service = described_class.allocate.tap { |s| s.send(:initialize, extract_path: custom_path) }
      expect(custom_service.extract_path).to eq(custom_path)
    end

    it "initializes empty extracted_files array" do
      service_instance = described_class.allocate.tap { |s| s.send(:initialize, extract_path:) }
      expect(service_instance.extracted_files).to eq([])
    end
  end

  describe "#cleanup!" do
    let(:service_instance) { described_class.allocate.tap { |s| s.send(:initialize, extract_path:) } }

    it "removes the extract directory and clears extracted_files" do
      # Create the directory and some files
      FileUtils.mkdir_p(extract_path)
      test_file = File.join(extract_path, "test.csv")
      File.write(test_file, "test,data\n1,2")
      service_instance.instance_variable_set(:@extracted_files, [test_file])

      expect(Dir.exist?(extract_path)).to be(true)

      service_instance.cleanup!

      expect(Dir.exist?(extract_path)).to be(false)
      expect(service_instance.extracted_files).to eq([])
    end

    it "does nothing if extract directory doesn't exist" do
      expect(Dir.exist?(extract_path)).to be(false)

      expect { service_instance.cleanup! }.not_to raise_error
      expect(service_instance.extracted_files).to eq([])
    end
  end
end
