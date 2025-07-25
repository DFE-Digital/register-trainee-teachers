# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolData::ImportService do
  include ActiveSupport::Testing::TimeHelpers

  let(:download_record) { create(:school_data_download, :running) }
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

      it "updates download record status to completed" do
        expect { subject }.to change { download_record.reload.status }
          .from("running").to("completed")
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
        existing_school

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

      it "tracks import statistics correctly and updates download record" do
        existing_school
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

      context "when lead partner already has correct name" do
        let!(:lead_partner) { create(:lead_partner, :school, school: school_with_lead_partner, name: "School With Lead Partner") }

        it "does not count already-correct names as updates" do
          result = subject

          expect(result[:lead_partners_updated]).to eq(0)
        end
      end
    end

    context "fail fast behavior" do
      context "when CSV file does not exist" do
        let(:filtered_csv_path) { "/nonexistent/path/file.csv" }

        it "fails immediately" do
          expect { subject }.to raise_error(Errno::ENOENT)
        end
      end

      context "when individual school import fails" do
        let(:invalid_csv_content) do
          [
            ["URN", "EstablishmentName", "TypeOfEstablishment (code)", "Postcode", "Town", "Address3", "Locality", "OpenDate"],
            ["123456", "Test Primary School", "1", "AB1 2CD", "TestTown", "", "", "2020-01-01"],
            ["234567", "", "10", "EF3 4GH", "TestCity", "", "", "2019-05-15"], # Missing name will trigger validation error
            ["345678", "Test Secondary School", "15", "IJ5 6KL", "", "TestVillage", "", ""],
          ]
        end

        before do
          CSV.open(filtered_csv_path, "w") do |csv|
            invalid_csv_content.each { |row| csv << row }
          end
        end

        it "fails the entire import immediately" do
          expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
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
  end
end
