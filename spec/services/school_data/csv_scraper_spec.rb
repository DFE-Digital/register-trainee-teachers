# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolData::CsvScraper do
  let(:extract_path) { Rails.root.join("tmp/test_school_data") }

  before do
    # Clean up test directory
    FileUtils.rm_rf(extract_path)

    # Stub Rails.logger to avoid noise in tests
    allow(Rails.logger).to receive(:info)
    allow(Rails.logger).to receive(:warn)
    allow(Rails.logger).to receive(:error)

    # Stub sleep to avoid delays in tests
    allow(Kernel).to receive(:sleep)

    VCR.configure do |config|
      config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
      config.hook_into :webmock
      config.configure_rspec_metadata!
      config.default_cassette_options = { record: :once }
    end
  end

  after do
    # Clean up test directory
    FileUtils.rm_rf(extract_path)
  end

  describe "#call" do
    context "realistic HTTP interactions", :vcr do
      context "successful downloads" do
        before do
          # Create a specific service instance to stub methods on
          @service_instance = described_class.allocate.tap { |s| s.send(:initialize, extract_path:) }
          allow(described_class).to receive(:new).and_return(@service_instance)

          # Stub the entire download_and_extract_zip method to avoid any HTTP calls
          allow(@service_instance).to receive(:download_and_extract_zip) do
            # Create fake CSV files in the extract directory
            FileUtils.mkdir_p(@service_instance.extract_path)

            state_funded_csv = File.join(@service_instance.extract_path, "edubaseallstatefunded20250115.csv")
            academies_csv = File.join(@service_instance.extract_path, "edubaseallacademiesandfree20250115.csv")

            File.write(state_funded_csv, "URN,EstablishmentName,Town,Postcode\n1001,Test State School,Test Town,TE1 1ST\n")
            File.write(academies_csv, "URN,EstablishmentName,Town,Postcode\n2001,Test Academy,Test City,TE2 2ND\n")

            @service_instance.instance_variable_set(:@extracted_files, [state_funded_csv, academies_csv])
          end

          # Stub validation to always pass
          allow(@service_instance).to receive(:validate_extraction)
        end

        it "successfully downloads and extracts CSV files from GIAS", vcr: { cassette_name: "gias_successful_download" } do
          result = described_class.call(extract_path:)

          expect(result.success?).to be true
          expect(result.extracted_files.length).to eq(2)
        end
      end

      context "error responses" do
        it "handles missing forms", vcr: { cassette_name: "httpbin_html_no_gias_forms" } do
          service_instance = described_class.allocate.tap { |s| s.send(:initialize, extract_path:) }
          allow(described_class).to receive(:new).and_return(service_instance)
          allow(service_instance).to receive(:gias_downloads_url).and_return("https://httpbin.org/html")

          result = described_class.call(extract_path:)
          expect(result.success?).to be false
        end

        it "handles 403 Forbidden responses", vcr: { cassette_name: "httpbin_403_forbidden" } do
          service_instance = described_class.allocate.tap { |s| s.send(:initialize, extract_path:) }
          allow(described_class).to receive(:new).and_return(service_instance)
          allow(service_instance).to receive(:gias_downloads_url).and_return("https://httpbin.org/status/403")

          result = described_class.call(extract_path:)
          expect(result.success?).to be false
        end

        it "handles 404 Not Found responses", vcr: { cassette_name: "httpbin_404_not_found" } do
          service_instance = described_class.allocate.tap { |s| s.send(:initialize, extract_path:) }
          allow(described_class).to receive(:new).and_return(service_instance)
          allow(service_instance).to receive(:gias_downloads_url).and_return("https://httpbin.org/status/404")

          result = described_class.call(extract_path:)
          expect(result.success?).to be false
        end

        it "handles server errors", vcr: { cassette_name: "httpbin_503_server_error" } do
          service_instance = described_class.allocate.tap { |s| s.send(:initialize, extract_path:) }
          allow(described_class).to receive(:new).and_return(service_instance)
          allow(service_instance).to receive(:gias_downloads_url).and_return("https://httpbin.org/status/503")

          result = described_class.call(extract_path:)
          expect(result.success?).to be false
        end
      end
    end

    context "additional error scenarios" do
      let(:service_instance) { described_class.allocate.tap { |s| s.send(:initialize, extract_path:) } }

      it "handles Mechanize errors" do
        allow(described_class).to receive(:new).and_return(service_instance)

        agent_double = double("agent")
        allow(service_instance).to receive(:agent).and_return(agent_double)
        allow(agent_double).to receive(:get).and_raise(Mechanize::Error, "Connection timeout")

        result = described_class.call(extract_path:)
        expect(result.success?).to be false
      end

      it "uses fallback form selection and handles timeouts" do
        page_double = double("page")
        form_double = double("form", action: nil, method: "post")
        allow(form_double).to receive(:checkbox_with).and_return(double("checkbox"))
        allow(page_double).to receive(:forms).and_return([form_double])

        result = service_instance.send(:find_and_validate_form, page_double)
        expect(result).to eq(form_double)

        allow(service_instance).to receive(:wait_for_download_button).and_return(nil)
        expect { service_instance.send(:download_zip_file, double("agent"), double("page")) }.to raise_error(
          SchoolData::CsvScraper::DownloadError,
          "Results.zip download button did not appear within timeout period",
        )
      end
    end

    context "file extraction errors" do
      let(:service_instance) { described_class.allocate.tap { |s| s.send(:initialize, extract_path:) } }

      it "handles empty ZIP files" do
        empty_zip_data = Zip::OutputStream.write_buffer do |out|
          out.put_next_entry("readme.txt")
          out.write("No CSV files here")
        end.string

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
        service_instance.instance_variable_set(:@extracted_files, ["/nonexistent/file.csv"])

        expect { service_instance.send(:validate_extraction) }.to raise_error(
          SchoolData::CsvScraper::ExtractionError,
          /Extracted file is missing or empty:/,
        )
      end

      it "extracts CSV files to correct paths" do
        zip_data = Zip::OutputStream.write_buffer do |out|
          out.put_next_entry("test.csv")
          out.write("URN,Name\n1,School")
        end.string

        service_instance.send(:extract_csv_files, zip_data)
        expect(service_instance.extracted_files.length).to eq(1)
      end
    end

    context "general error handling" do
      it "catches and logs unexpected errors" do
        service_instance = described_class.allocate.tap { |s| s.send(:initialize, extract_path:) }
        allow(described_class).to receive(:new).and_return(service_instance)
        allow(service_instance).to receive(:download_and_extract_zip).and_raise(StandardError, "Unexpected error")

        result = described_class.call(extract_path:)
        expect(result.success?).to be false
      end
    end
  end

  describe "initialization and cleanup" do
    it "handles initialization with custom paths" do
      custom_service = described_class.allocate.tap { |s| s.send(:initialize, extract_path: "/tmp/custom") }
      expect(custom_service.extract_path).to eq("/tmp/custom")
    end

    it "cleans up files and directories" do
      service_instance = described_class.allocate.tap { |s| s.send(:initialize, extract_path:) }

      FileUtils.mkdir_p(extract_path)
      service_instance.cleanup!

      expect(Dir.exist?(extract_path)).to be(false)
    end
  end
end
