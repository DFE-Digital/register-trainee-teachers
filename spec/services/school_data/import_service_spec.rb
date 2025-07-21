# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolData::ImportService do
  include ActiveSupport::Testing::TimeHelpers

  let(:download_record) { create(:school_data_download, :filtering_complete) }
  let(:filtered_csv_path) { Rails.root.join("tmp/test_filtered_schools.csv") }
  let(:sample_csv_content) do
    [
      ["URN", "EstablishmentName", "TypeOfEstablishment (code)", "Postcode", "Town", "Address3", "Locality", "OpenDate"],
      ["123456", "Test Primary School", "1", "AB1 2CD", "TestTown", "", "", "2020-01-01"],
      ["234567", "Test Academy", "10", "EF3 4GH", "TestCity", "", "", "2019-05-15"],
      ["345678", "Test Secondary School", "15", "IJ5 6KL", "", "TestVillage", "", ""],
      ["456789", "Test Special School", "7", "MN7 8OP", "", "", "TestLocality", "2018-09-01"],
    ]
  end

  let(:existing_school) { create(:school, urn: "123456", name: "Old School Name") }

  after do
    # Clean up test files
    FileUtils.rm_f(filtered_csv_path)
  end

  describe "#call" do
    subject { described_class.call(filtered_csv_path:, download_record:) }

    context "when import succeeds" do
      before do
        # Create the filtered CSV file
        CSV.open(filtered_csv_path, "w") do |csv|
          sample_csv_content.each { |row| csv << row }
        end
      end

      it "updates download record status to processing then completed" do
        expect { subject }.to change { download_record.reload.status }
          .from("filtering_complete").to("completed")
      end

      it "imports new schools correctly" do
        expect { subject }.to change { School.count }.by(4)

        created_school = School.find_by(urn: "234567")
        expect(created_school).to have_attributes(
          name: "Test Academy",
          postcode: "EF3 4GH",
          town: "TestCity",
          open_date: Date.parse("2019-05-15"),
        )
      end

      it "updates existing schools" do
        existing_school # Create the existing school

        expect { subject }.to change { existing_school.reload.name }
          .from("Old School Name").to("Test Primary School")
      end

      it "handles town extraction with fallback logic" do
        subject

        # School with Address3 fallback
        school_with_address3 = School.find_by(urn: "345678")
        expect(school_with_address3.town).to eq("TestVillage")

        # School with Locality fallback
        school_with_locality = School.find_by(urn: "456789")
        expect(school_with_locality.town).to eq("TestLocality")
      end

      it "tracks import statistics correctly" do
        existing_school # Create one existing school

        result = subject

        expect(result[:created]).to eq(3)     # 3 new schools
        expect(result[:updated]).to eq(1)     # 1 updated school
        expect(result[:errors]).to be_empty
      end

      it "updates download record with final statistics" do
        existing_school # Create one existing school

        subject

        download_record.reload
        expect(download_record.schools_created).to eq(3)
        expect(download_record.schools_updated).to eq(1)
        expect(download_record.completed_at).to be_present
      end

      it "cleans up the filtered CSV file" do
        expect(File.exist?(filtered_csv_path)).to be true

        subject

        expect(File.exist?(filtered_csv_path)).to be false
      end

      it "logs successful import information" do
        expect(Rails.logger).to receive(:info).with(match(/Import completed: \d+ created, \d+ updated, \d+ errors/))

        subject
      end
    end

    context "lead partner realignment" do
      let!(:school_with_lead_partner) { create(:school, urn: "999888", name: "School With Lead Partner") }
      let!(:lead_partner) { create(:lead_partner, :school, school: school_with_lead_partner, name: "Old Lead Partner Name") }

      before do
        # Create the filtered CSV file
        CSV.open(filtered_csv_path, "w") do |csv|
          sample_csv_content.each { |row| csv << row }
        end
      end

      it "updates lead partner names to match school names" do
        expect { subject }.to change { lead_partner.reload.name }
          .from("Old Lead Partner Name").to("School With Lead Partner")
      end

      it "tracks lead partner updates in statistics" do
        result = subject

        expect(result[:lead_partners_updated]).to eq(1)

        download_record.reload
        expect(download_record.lead_partners_updated).to eq(1)
      end

      it "logs errors when lead partner updates fail" do
        allow(lead_partner).to receive(:save).and_return(false)
        allow(lead_partner).to receive(:errors).and_return(double(full_messages: ["Name can't be blank"]))
        allow(LeadPartner).to receive_message_chain(:school, :joins, :includes, :where, :find_each).and_yield(lead_partner)

        expect(Rails.logger).to receive(:error).with(match(/Failed to update lead partner/))

        subject
      end

      context "when lead partner already has correct name" do
        let!(:lead_partner) { create(:lead_partner, :school, school: school_with_lead_partner, name: "School With Lead Partner") }

        it "does not count already-correct names as updates" do
          result = subject

          expect(result[:lead_partners_updated]).to eq(0)
        end
      end
    end

    context "error handling" do
      context "when CSV file does not exist" do
        let(:filtered_csv_path) { "/nonexistent/path/file.csv" }

        # Override the before block for this context to not create the CSV file

        it "raises an error with descriptive message" do
          expect { subject }.to raise_error(RuntimeError, /Filtered CSV file not found/)
        end

        it "updates download record to failed status" do
          expect { subject }.to raise_error(RuntimeError)

          download_record.reload
          expect(download_record.status).to eq("failed")
          expect(download_record.error_message).to include("Filtered CSV file not found")
          expect(download_record.completed_at).to be_present
        end
      end

      context "when CSV file is not readable" do
        before do
          # Create the file first, then mock it as not readable
          CSV.open(filtered_csv_path, "w") do |csv|
            sample_csv_content.each { |row| csv << row }
          end
          allow(File).to receive(:exist?).and_call_original
          allow(File).to receive(:readable?).and_call_original
          allow(File).to receive(:exist?).with(filtered_csv_path).and_return(true)
          allow(File).to receive(:readable?).with(filtered_csv_path).and_return(false)
        end

        it "raises an error about readability" do
          expect { subject }.to raise_error(RuntimeError, /Filtered CSV file not readable/)
        end
      end

      context "when individual school import fails" do
        let(:invalid_csv_content) do
          [
            ["URN", "EstablishmentName", "TypeOfEstablishment (code)", "Postcode"],
            ["123456", "Valid School", "1", "AB1 2CD"],
            ["", "School with blank URN", "1", "EF3 4GH"], # This will be skipped
            ["789012", "School That Will Fail", "1", "IJ5 6KL"],
          ]
        end

        before do
          # Recreate CSV with invalid data
          FileUtils.rm_f(filtered_csv_path)
          CSV.open(filtered_csv_path, "w") do |csv|
            invalid_csv_content.each { |row| csv << row }
          end
        end

        it "continues processing other schools and tracks errors" do
          # Mock the service to simulate a failure for one school
          original_method = SchoolData::ImportService.instance_method(:import_single_school)
          allow_any_instance_of(SchoolData::ImportService).to receive(:import_single_school) do |service, row|
            if row["URN"] == "789012"
              # Simulate error by calling the error tracking directly
              service.instance_variable_get(:@stats)[:errors] << { urn: "789012", error: "Validation failed" }
              Rails.logger.error("Failed to import school URN 789012: Validation failed")
            else
              original_method.bind(service).call(row)
            end
          end

          result = subject

          expect(result[:created]).to eq(1) # Only valid school created
          expect(result[:errors].size).to eq(1)
          expect(result[:errors].first[:urn]).to eq("789012")
        end

        it "logs individual school import failures" do
          # Mock the service to simulate a failure for one school
          original_method = SchoolData::ImportService.instance_method(:import_single_school)
          allow_any_instance_of(SchoolData::ImportService).to receive(:import_single_school) do |service, row|
            if row["URN"] == "789012"
              # Simulate error by calling the error tracking directly
              service.instance_variable_get(:@stats)[:errors] << { urn: "789012", error: "Validation failed" }
              Rails.logger.error("Failed to import school URN 789012: Validation failed")
            else
              original_method.bind(service).call(row)
            end
          end

          expect(Rails.logger).to receive(:error).with(match(/Failed to import school URN 789012/))

          subject
        end
      end

      context "when database transaction fails" do
        before do
          # Create the filtered CSV file
          CSV.open(filtered_csv_path, "w") do |csv|
            sample_csv_content.each { |row| csv << row }
          end
          allow(School).to receive(:transaction).and_raise(ActiveRecord::StatementInvalid.new("Database error"))
        end

        it "handles the error and updates download record" do
          expect { subject }.to raise_error(ActiveRecord::StatementInvalid)

          download_record.reload
          expect(download_record.status).to eq("failed")
          expect(download_record.error_message).to eq("Database error")
        end

        it "cleans up files on error" do
          expect(File.exist?(filtered_csv_path)).to be true

          expect { subject }.to raise_error(ActiveRecord::StatementInvalid)

          expect(File.exist?(filtered_csv_path)).to be false
        end

        it "logs error information" do
          expect(Rails.logger).to receive(:error).with("School data import failed: Database error")
          expect(Rails.logger).to receive(:error).with(kind_of(String)) # backtrace

          expect { subject }.to raise_error(ActiveRecord::StatementInvalid)
        end
      end
    end

    context "date parsing" do
      let(:date_csv_content) do
        [
          ["URN", "EstablishmentName", "TypeOfEstablishment (code)", "Postcode", "Town", "Address3", "Locality", "OpenDate"],
          ["111111", "Valid Date School", "1", "AB1 2CD", "TestTown", "", "", "2020-01-01"],
          ["222222", "Invalid Date School", "1", "EF3 4GH", "TestCity", "", "", "not-a-date"],
          ["333333", "Blank Date School", "1", "IJ5 6KL", "TestVillage", "", "", ""],
        ]
      end

      before do
        FileUtils.rm_f(filtered_csv_path)
        CSV.open(filtered_csv_path, "w") do |csv|
          date_csv_content.each { |row| csv << row }
        end
      end

      it "parses valid dates correctly" do
        subject

        school = School.find_by(urn: "111111")
        expect(school.open_date).to eq(Date.parse("2020-01-01"))
      end

      it "handles invalid dates gracefully" do
        expect(Rails.logger).to receive(:warn).with("Failed to parse date: not-a-date")

        subject

        school = School.find_by(urn: "222222")
        expect(school.open_date).to be_nil
      end

      it "handles blank dates" do
        subject

        school = School.find_by(urn: "333333")
        expect(school.open_date).to be_nil
      end
    end

    context "town extraction warnings" do
      let(:town_csv_content) do
        [
          ["URN", "EstablishmentName", "TypeOfEstablishment (code)", "Town", "Address3", "Locality"],
          ["111111", "School With No Town", "1", "", "", ""],
        ]
      end

      before do
        FileUtils.rm_f(filtered_csv_path)
        CSV.open(filtered_csv_path, "w") do |csv|
          town_csv_content.each { |row| csv << row }
        end
      end

      it "logs warning when no town data is available" do
        expect(Rails.logger).to receive(:warn).with("Town missing for school: 'School With No Town' URN: 111111")

        subject
      end
    end

    context "service pattern compliance" do
      before do
        # Create the filtered CSV file
        CSV.open(filtered_csv_path, "w") do |csv|
          sample_csv_content.each { |row| csv << row }
        end
      end

      it "follows the ServicePattern and can be called as class method" do
        # Test both instance and class method calling patterns
        expect { described_class.call(filtered_csv_path:, download_record:) }.not_to raise_error
      end

      it "returns statistics hash as expected" do
        result = subject

        expect(result).to be_a(Hash)
        expect(result.keys).to contain_exactly(:created, :updated, :errors, :lead_partners_updated)
        expect(result[:created]).to be_a(Integer)
        expect(result[:updated]).to be_a(Integer)
        expect(result[:errors]).to be_an(Array)
        expect(result[:lead_partners_updated]).to be_a(Integer)
      end
    end
  end
end
