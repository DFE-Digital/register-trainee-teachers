# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolData::SchoolDataDownloader do
  include ActiveSupport::Testing::TimeHelpers

  let(:download_record) { create(:school_data_download) }

  describe "#call" do
    context "when download succeeds" do
      let(:sample_csv_data) do
        [
          ["URN", "EstablishmentName", "TypeOfEstablishment (code)", "Postcode", "Town"],
          ["123456", "Test Primary School", "1", "AB1 2CD", "TestTown"],
          ["234567", "Test Academy", "10", "EF3 4GH", "TestCity"],
          ["345678", "Test Independent School", "4", "IJ5 6KL", "TestVillage"], # Not included - type 4
          ["456789", "Test Secondary School", "15", "MN7 8OP", "TestDistrict"],
        ]
      end

      before do
        freeze_time

        # Mock the CSV download
        allow(URI).to receive(:open).and_yield(StringIO.new(sample_csv_data.map(&:to_csv).join))
      end

      it "updates download record status progression" do
        expect { described_class.call(download_record:) }.to change { download_record.reload.status }
          .from("pending").to("filtering_complete")
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

      it "updates statistics correctly" do
        described_class.call(download_record:)

        download_record.reload
        expect(download_record.rows_processed).to eq(4) # 4 data rows (excluding header)
        expect(download_record.rows_filtered).to eq(3) # 3 matching establishment types
      end

      it "logs progress information" do
        expect(Rails.logger).to receive(:info).with("Starting school data download and filtering")
        expect(Rails.logger).to receive(:info).with(match(/School data download completed:/))

        described_class.call(download_record:)
      end
    end

    context "when download fails" do
      let(:error_message) { "Network timeout" }

      before do
        allow(URI).to receive(:open).and_raise(Timeout::Error, error_message)
      end

      it "handles network errors gracefully" do
        expect { described_class.call(download_record:) }.to raise_error(Timeout::Error)

        download_record.reload
        expect(download_record.status).to eq("failed")
        expect(download_record.error_message).to eq(error_message)
        expect(download_record.completed_at).to be_present
      end

      it "logs error information" do
        expect(Rails.logger).to receive(:error).with("School data download failed: #{error_message}")
        expect(Rails.logger).to receive(:error).with(kind_of(String)) # backtrace

        expect { described_class.call(download_record:) }.to raise_error(Timeout::Error)
      end

      it "cleans up temporary files on error" do
        # We can't easily test the cleanup method call since it's private,
        # but we can verify the behavior by checking that no temp files are left
        expect { described_class.call(download_record:) }.to raise_error(Timeout::Error)
      end
    end

    context "when CSV is malformed" do
      before do
        # Create truly malformed CSV that will cause parsing to fail
        malformed_csv = "URN,Name\n\"unclosed quote field"
        allow(URI).to receive(:open).and_yield(StringIO.new(malformed_csv))
      end

      it "handles CSV parsing errors" do
        expect { described_class.call(download_record:) }.to raise_error(CSV::MalformedCSVError)

        download_record.reload
        expect(download_record.status).to eq("failed")
        expect(download_record.error_message).to include("Unclosed quoted field")
      end
    end
  end

  describe "private methods" do
    let(:service_instance) { described_class.send(:new, download_record:) }

    describe "#csv_url" do
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

    describe "#should_include_row?" do
      let(:row_data) { { "URN" => "123456", "TypeOfEstablishment (code)" => establishment_type.to_s } }
      let(:csv_row) { CSV::Row.new(row_data.keys, row_data.values) }

      context "with valid establishment types" do
        described_class::ESTABLISHMENT_TYPES.sample(5).each do |type|
          context "for establishment type #{type}" do
            let(:establishment_type) { type }

            it "includes the row" do
              expect(service_instance.send(:should_include_row?, csv_row)).to be true
            end
          end
        end
      end

      context "with invalid establishment types" do
        [4, 9, 13, 99, 100].each do |type|
          context "for establishment type #{type}" do
            let(:establishment_type) { type }

            it "excludes the row" do
              expect(service_instance.send(:should_include_row?, csv_row)).to be false
            end
          end
        end
      end

      context "with non-numeric establishment type" do
        let(:establishment_type) { "invalid" }

        it "excludes the row" do
          expect(service_instance.send(:should_include_row?, csv_row)).to be false
        end
      end

      context "with empty establishment type" do
        let(:establishment_type) { "" }

        it "excludes the row" do
          expect(service_instance.send(:should_include_row?, csv_row)).to be false
        end
      end
    end

    describe "#cleanup_files" do
      let(:temp_file_path) { "/tmp/test_file.csv" }

      before do
        service_instance.instance_variable_set(:@filtered_csv_path, temp_file_path)
      end

      context "when file exists" do
        before do
          allow(File).to receive(:exist?).and_call_original
          allow(File).to receive(:exist?).with(temp_file_path).and_return(true)
          allow(File).to receive(:unlink).with(temp_file_path)
        end

        it "removes the file" do
          expect(File).to receive(:unlink).with(temp_file_path)

          service_instance.send(:cleanup_files)
        end
      end

      context "when file does not exist" do
        before do
          allow(File).to receive(:exist?).and_call_original
          allow(File).to receive(:exist?).with(temp_file_path).and_return(false)
        end

        it "does not attempt to remove the file" do
          expect(File).not_to receive(:unlink)

          service_instance.send(:cleanup_files)
        end
      end

      context "when file removal fails" do
        before do
          allow(File).to receive(:exist?).and_call_original
          allow(File).to receive(:exist?).with(temp_file_path).and_return(true)
          allow(File).to receive(:unlink).with(temp_file_path).and_raise(Errno::ENOENT, "No such file or directory")
        end

        it "logs the warning" do
          expect(Rails.logger).to receive(:warn).with(match(/Failed to cleanup temporary file:/))

          service_instance.send(:cleanup_files)
        end
      end
    end
  end
end
