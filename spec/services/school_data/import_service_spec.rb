# frozen_string_literal: true

require "rails_helper"
require "tempfile"

RSpec.describe SchoolData::ImportService do
  let(:download_record) { create(:school_data_download, status: :extracting) }

  let(:csv_header) do
    '"URN","LA (code)","LA (name)","EstablishmentNumber","EstablishmentName","TypeOfEstablishment (name)","EstablishmentStatus (name)","ReasonEstablishmentOpened (name)","OpenDate","PhaseOfEducation (name)","StatutoryLowAge","StatutoryHighAge","Boarders (name)","OfficialSixthForm (name)","Gender (name)","ReligiousCharacter (name)","AdmissionsPolicy (name)","UKPRN","Street","Locality","Address3","Town","County (name)","Postcode","SchoolWebsite","TelephoneNum","FaxNum","HeadTitle (name)","HeadFirstName","HeadLastName","HeadPreferredJobTitle","GOR (name)","ParliamentaryConstituency (code)","ParliamentaryConstituency (name)"'
  end

  let(:school_row_one) do
    '"100001",,,,"Test Primary School",,,,"2020-01-01",,,,,,,,,,,"Test Locality","Test Address3","Test Town",,"SW1A 1AA",,,,,,,,,,'
  end

  let(:school_row_two) do
    '"100002",,,,"Test Secondary School",,,,"2019-09-01",,,,,,,,,,,"Secondary Locality",,"Secondary Town",,"E1 6AN",,,,,,,,,,'
  end

  let(:duplicate_school_row) do
    '"100001",,,,"Duplicate Primary School",,,,"2021-01-01",,,,,,,,,,,"Different Locality","Different Address","Different Town",,"SW1A 2BB",,,,,,,,,,'
  end

  let(:invalid_school_row) do
    '"",,,,"Invalid School",,,,"invalid-date",,,,,,,,,,,"",,"",,"",,,,,,,,,,'
  end

  let(:csv_one_content) do
    <<~CSV
      #{csv_header}
      #{school_row_one}
      #{duplicate_school_row}
    CSV
  end

  let(:csv_two_content) do
    <<~CSV
      #{csv_header}
      #{school_row_two}
      #{duplicate_school_row}
      #{invalid_school_row}
    CSV
  end

  let(:csv_file_one) do
    Tempfile.new(["academies", ".csv"]).tap do |f|
      f.write(csv_one_content)
      f.flush
      f.close
    end
  end

  let(:csv_file_two) do
    Tempfile.new(["state_funded", ".csv"]).tap do |f|
      f.write(csv_two_content)
      f.flush
      f.close
    end
  end

  let(:csv_files) { [csv_file_one.path, csv_file_two.path] }

  after do
    csv_file_one&.unlink
    csv_file_two&.unlink
  end

  describe "#call" do
    subject(:service_call) { described_class.call(csv_files:, download_record:) }

    context "with valid CSV files" do
      it "processes CSV files and imports schools successfully" do
        result = service_call

        expect(result[:created]).to eq(2)
        expect(result[:updated]).to eq(0)
        expect(result[:errors]).to be_empty
        expect(result[:lead_partners_updated]).to eq(0)

        # Verify schools were created correctly
        school_one = School.find_by(urn: "100001")
        expect(school_one).to be_present
        expect(school_one.name).to eq("Test Primary School")
        expect(school_one.town).to eq("Test Town")
        expect(school_one.postcode).to eq("SW1A 1AA")
        expect(school_one.open_date).to eq(Date.parse("2020-01-01"))

        school_two = School.find_by(urn: "100002")
        expect(school_two).to be_present
        expect(school_two.name).to eq("Test Secondary School")
        expect(school_two.town).to eq("Secondary Town")
        expect(school_two.postcode).to eq("E1 6AN")
        expect(school_two.open_date).to eq(Date.parse("2019-09-01"))

        # Verify no duplicate schools were created
        expect(School.where(urn: "100001").count).to eq(1)
      end

      it "updates the download record status" do
        expect { service_call }
          .to change { download_record.reload.status }.from("extracting").to("completed")
          .and change { download_record.completed_at }.from(nil)
          .and change { download_record.file_count }.from(nil).to(2)
          .and change { download_record.schools_created }.from(0).to(2)

        expect(download_record.reload.schools_updated).to eq(0)
      end

      it "handles missing town data with fallback logic" do
        missing_town_csv = <<~CSV
          #{csv_header}
          "100003",,,,"School Without Town",,,,"2020-01-01",,,,,,,,,,,"Fallback Locality","","",,"SW1A 1AA",,,,,,,,,,
        CSV

        missing_town_file = Tempfile.new(["missing_town", ".csv"]).tap do |f|
          f.write(missing_town_csv)
          f.flush
          f.close
        end

        begin
          expect(Rails.logger).to receive(:warn).with(/Town missing for school/)

          described_class.call(csv_files: [missing_town_file.path, csv_file_two.path], download_record: download_record)

          school = School.find_by(urn: "100003")
          expect(school.town).to eq("Fallback Locality")
        ensure
          missing_town_file&.unlink
        end
      end

      context "when schools already exist" do
        let!(:existing_school) { create(:school, urn: "100001", name: "Old Name", town: "Old Town") }

        it "updates existing schools" do
          result = described_class.call(csv_files:, download_record:)

          expect(result[:created]).to eq(1)
          expect(result[:updated]).to eq(1)

          existing_school.reload
          expect(existing_school.name).to eq("Test Primary School")
          expect(existing_school.town).to eq("Test Town")
          expect(existing_school.postcode).to eq("SW1A 1AA")
        end
      end

      context "with lead partner realignment" do
        let!(:school) { create(:school, urn: "100001", name: "Test Primary School") }
        let!(:lead_partner) { create(:lead_partner, :school, school: school, name: "Old School Name") }

        before do
          # Ensure school exists before running the service
          school.reload
        end

        it "realigns lead partner names with school names" do
          result = described_class.call(csv_files:, download_record:)

          expect(result[:lead_partners_updated]).to eq(1)
          expect(lead_partner.reload.name).to eq("Test Primary School")
        end
      end
    end

    context "with invalid CSV files" do
      context "when wrong number of files provided" do
        let(:csv_files) { [csv_file_one.path] }

        it "raises an error" do
          expect { described_class.call(csv_files:, download_record:) }.to raise_error("Expected 2 CSV files, got 1")
          expect(download_record.reload.status).to eq("failed")
          expect(download_record.error_message).to eq("Expected 2 CSV files, got 1")
        end
      end

      context "when file does not exist" do
        let(:csv_files) { [csv_file_one.path, "/non/existent/file.csv"] }

        it "raises an error" do
          expect { described_class.call(csv_files:, download_record:) }.to raise_error(/CSV file not found/)
          expect(download_record.reload.status).to eq("failed")
        end
      end

      context "when file is not readable" do
        before do
          allow(File).to receive(:readable?).and_call_original
          allow(File).to receive(:readable?).with(csv_file_two.path).and_return(false)
        end

        it "raises an error" do
          expect { described_class.call(csv_files:, download_record:) }.to raise_error(/CSV file not readable/)
          expect(download_record.reload.status).to eq("failed")
        end
      end
    end

    context "with school import errors" do
      before do
        school_instance = instance_double(School)
        allow(School).to receive(:find_or_initialize_by).and_return(school_instance)
        allow(school_instance).to receive(:new_record?).and_return(true)
        allow(school_instance).to receive(:assign_attributes)
        allow(school_instance).to receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(School.new))
      end

      it "collects errors and continues processing" do
        result = described_class.call(csv_files:, download_record:)

        expect(result[:created]).to eq(0)
        expect(result[:updated]).to eq(0)
        expect(result[:errors].size).to eq(2)
        expect(result[:errors].first[:error]).to include("Validation failed")
      end

      it "still updates the download record as completed" do
        described_class.call(csv_files:, download_record:)

        expect(download_record.reload.status).to eq("completed")
      end
    end

    context "with date parsing errors" do
      let(:invalid_date_csv) do
        <<~CSV
          #{csv_header}
          "100005",,,,"School With Invalid Date",,,,"not-a-date",,,,,,,,,,,"Test Locality",,"Test Town",,"SW1A 1AA",,,,,,,,,,
        CSV
      end

      let(:invalid_date_file) do
        Tempfile.new(["invalid_date", ".csv"]).tap do |f|
          f.write(invalid_date_csv)
          f.flush
          f.close
        end
      end

      it "handles invalid dates gracefully" do
        expect(Rails.logger).to receive(:warn).with(/Failed to parse date/)

        begin
          described_class.call(csv_files: [invalid_date_file.path, csv_file_two.path], download_record: download_record)

          school = School.find_by(urn: "100005")
          expect(school.open_date).to be_nil
        ensure
          invalid_date_file&.unlink
        end
      end
    end

    context "with transaction rollback" do
      before do
        allow(School).to receive(:transaction).and_raise(ActiveRecord::StatementInvalid, "Database error")
      end

      it "handles transaction errors and updates download record" do
        expect { described_class.call(csv_files:, download_record:) }.to raise_error(ActiveRecord::StatementInvalid)

        expect(download_record.reload.status).to eq("failed")
        expect(download_record.error_message).to eq("Database error")
      end
    end

    it "cleans up temporary files" do
      # Check that no temporary files remain after the service completes
      temp_files_before = Rails.root.glob("tmp/schools_gias_combined_*.csv")

      described_class.call(csv_files:, download_record:)

      temp_files_after = Rails.root.glob("tmp/schools_gias_combined_*.csv")
      expect(temp_files_after.size).to eq(temp_files_before.size)
    end

    it "logs import completion" do
      expect(Rails.logger).to receive(:info).with(/Import completed/).at_least(:once)
      allow(Rails.logger).to receive(:info) # Allow other info messages

      described_class.call(csv_files:, download_record:)
    end
  end

  describe "encoding handling" do
    it "reads CSV files with Windows-1251 encoding" do
      # This test ensures we maintain compatibility with GIAS CSV encoding
      expect(CSV).to receive(:read).with(csv_file_one.path, headers: true, encoding: "windows-1251:utf-8").and_call_original
      expect(CSV).to receive(:read).with(csv_file_two.path, headers: true, encoding: "windows-1251:utf-8").and_call_original

      described_class.call(csv_files:, download_record:)
    end
  end
end
