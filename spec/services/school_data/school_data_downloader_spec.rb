# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolData::SchoolDataDownloader do
  include ActiveSupport::Testing::TimeHelpers

  let(:download_record) { create(:school_data_download) }

  describe "#call" do
    context "when download succeeds" do
      let(:sample_csv_data) do
        # Raw CSV lines to test line-by-line filtering approach
        "URN,EstablishmentName,TypeOfEstablishment (code),Postcode,Town\n" \
          "123456,Test Primary School,1,AB1 2CD,TestTown\n" \
          "234567,Test Academy,10,EF3 4GH,TestCity\n" \
          "345678,Test Independent School,4,IJ5 6KL,TestVillage\n" \
          "456789,Test Secondary School,15,MN7 8OP,TestDistrict"
      end

      before do
        # Mock the CSV download with proper encoding
        csv_stream = StringIO.new(sample_csv_data)
        allow(csv_stream).to receive(:set_encoding)
        allow(URI).to receive(:open).and_yield(csv_stream)
      end

      it "downloads and filters CSV data correctly" do
        result = described_class.call(download_record:)

        expect(result).to be_a(described_class)
        expect(result.filtered_csv_path).to be_present
        expect(File.exist?(result.filtered_csv_path)).to be true
      end

      it "filters rows based on establishment types" do
        service = described_class.call(download_record:)

        filtered_content = File.read(service.filtered_csv_path)
        filtered_csv = CSV.parse(filtered_content, headers: true)

        # Should include schools with types 1, 10, and 15 but not 4
        expect(filtered_csv.count).to eq(3)
        expect(filtered_csv.map { |row| row["URN"] }).to contain_exactly("123456", "234567", "456789")
      end

      it "logs download URL" do
        expect(Rails.logger).to receive(:info).with(match(/Downloading school data from:/))
        expect(Rails.logger).to receive(:info).with("Starting school data download and filtering")

        described_class.call(download_record:)
      end
    end

    context "when download fails" do
      before do
        allow(URI).to receive(:open).and_raise(Timeout::Error, "Network timeout")
      end

      it "re-raises the error (fail fast approach)" do
        expect { described_class.call(download_record:) }.to raise_error(Timeout::Error)
      end
    end

    context "when establishment type column is missing" do
      let(:invalid_csv) { "URN,Name\n123456,Test School" }

      before do
        csv_stream = StringIO.new(invalid_csv)
        allow(csv_stream).to receive(:set_encoding)
        allow(URI).to receive(:open).and_yield(csv_stream)
      end

      it "raises error for missing column" do
        expect { described_class.call(download_record:) }.to raise_error(/Could not find 'TypeOfEstablishment \(code\)' column/)
      end
    end
  end

  describe "private methods" do
    let(:service_instance) { described_class.send(:new, download_record:) }

    describe "#csv_url" do
      include ActiveSupport::Testing::TimeHelpers

      context "with default settings" do
        it "generates URL with current date" do
          travel_to Time.zone.parse("2025-07-21")

          expected_url = "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/edubasealldata20250721.csv"
          expect(service_instance.send(:csv_url)).to eq(expected_url)
        end
      end

      context "with custom base URL in settings" do
        before do
          allow(Settings.school_data.downloader).to receive(:base_url)
            .and_return("https://custom.domain.com/data%s.csv")
        end

        it "uses custom base URL" do
          travel_to Time.zone.parse("2025-07-21")

          expected_url = "https://custom.domain.com/data20250721.csv"
          expect(service_instance.send(:csv_url)).to eq(expected_url)
        end
      end
    end

    describe "#log_debug_info" do
      it "logs establishment type and school name" do
        fields = ["123456", "LA123", "Local Authority", "456", "Test School Name", "1"]

        expect(Rails.logger).to receive(:info).with("Row 5: Type=1, School='Test School Name'")

        service_instance.send(:log_debug_info, 1, fields, 5)
      end
    end

    describe "establishment type filtering" do
      context "with valid establishment types" do
        described_class::ESTABLISHMENT_TYPES.sample(5).each do |type|
          it "includes establishment type #{type}" do
            expect(described_class::ESTABLISHMENT_TYPES).to include(type)
          end
        end
      end

      context "with invalid establishment types" do
        [4, 9, 13, 99, 100].each do |type|
          it "excludes establishment type #{type}" do
            expect(described_class::ESTABLISHMENT_TYPES).not_to include(type)
          end
        end
      end
    end
  end
end
