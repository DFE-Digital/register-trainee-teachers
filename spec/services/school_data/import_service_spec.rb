# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolData::ImportService do
  include ActiveSupport::Testing::TimeHelpers

  let(:download_record) { create(:school_data_download, :running) }
  let(:sample_csv_content) do
    <<~CSV
      URN,EstablishmentName,TypeOfEstablishment (code),Postcode,Town,Address3,Locality,OpenDate,CloseDate
      123456,Test Primary School,1,AB1 2CD,TestTown,,,2020-01-01,2023-07-20
      234567,Test Academy,10,EF3 4GH,TestCity,,,2019-05-15,2024-12-31
      345678,Test Secondary School,15,IJ5 6KL,,TestVillage,,,
      456789,Test Special School,7,MN7 8OP,,,TestLocality,2018-09-01,
      567890,Test Independent School,4,PQ9 0RS,TestPlace,,,2021-03-10,
      678901,Test Excluded School,29,QR1 2ST,TestTown,,,2020-06-01,
      999888,School With Lead Partner,20,ST1 2AB,LeadTown,,,2022-01-01,
    CSV
  end

  let(:existing_school) { create(:school, urn: "123456", name: "Old School Name") }
  let(:school_removed_from_gias) { create(:school, urn: "987645", name: "Removed from GIAS School") }

  describe "#call" do
    subject { described_class.call(csv_content: sample_csv_content, download_record: download_record) }

    context "when import succeeds" do
      it "updates download record status to completed" do
        expect { subject }.to change { download_record.reload.status }
          .from("running").to("completed")
      end

      it "imports new schools with valid establishment types" do
        expect { subject }.to change { School.count }.by(6)

        # Should import schools with types 1, 10, 15, 7, and 4 (not in EXCLUDED_ESTABLISHMENT_TYPES)
        expect(School.find_by(urn: "123456")).to have_attributes(
          name: "Test Primary School",
          postcode: "AB1 2CD",
          town: "TestTown",
          open_date: Date.parse("2020-01-01"),
        )

        expect(School.find_by(urn: "234567")).to have_attributes(
          name: "Test Academy",
          postcode: "EF3 4GH",
          town: "TestCity",
          open_date: Date.parse("2019-05-15"),
          close_date: Date.parse("2024-12-31"),
        )

        expect(School.find_by(urn: "345678")).to have_attributes(
          name: "Test Secondary School",
          postcode: "IJ5 6KL",
          town: "TestVillage",
        )

        expect(School.find_by(urn: "456789")).to have_attributes(
          name: "Test Special School",
          postcode: "MN7 8OP",
          town: "TestLocality",
          open_date: Date.parse("2018-09-01"),
        )

        expect(School.find_by(urn: "567890")).to have_attributes(
          name: "Test Independent School",
          postcode: "PQ9 0RS",
          town: "TestPlace",
          open_date: Date.parse("2021-03-10"),
        )
      end

      it "filters out schools with excluded establishment types" do
        subject

        # Should not import school with type 29 (in EXCLUDED_ESTABLISHMENT_TYPES)
        expect(School.find_by(urn: "678901")).to be_nil
      end

      it "updates existing schools" do
        existing_school

        expect { subject }.to change { existing_school.reload.name }
          .from("Old School Name").to("Test Primary School")
        expect(existing_school.close_date).to eq(Date.parse("2023-07-20"))
      end

      it "deletes schools no longer present in GIAS data" do
        school_removed_from_gias

        expect { subject }.to change { School.count }
          .by(5) # 6 imported - 1 removed = net +5

        expect(School.find_by(urn: "987645")).to be_nil
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

      it "tracks import and filtering statistics correctly" do
        existing_school
        school_removed_from_gias
        result = subject

        expect(result[:total_rows]).to eq(7)
        expect(result[:filtered_rows]).to eq(1) # Only type 29 filtered out
        expect(result[:created]).to eq(5) # 234567, 345678, 456789, 567890, 999888
        expect(result[:updated]).to eq(1) # 123456 existing school
        expect(result[:deleted]).to eq(1) # 987645

        download_record.reload
        expect(download_record.schools_created).to eq(5)
        expect(download_record.schools_updated).to eq(1)
        expect(download_record.schools_deleted).to eq(1)
        expect(download_record.completed_at).to be_present
      end

      it "logs filtering results" do
        existing_school
        school_removed_from_gias

        expect(Rails.logger).to receive(:info).with("Updated school: 123456 - Test Primary School")
        expect(Rails.logger).to receive(:info).with("Created school: 234567 - Test Academy")
        expect(Rails.logger).to receive(:info).with("Created school: 345678 - Test Secondary School")
        expect(Rails.logger).to receive(:info).with("Created school: 456789 - Test Special School")
        expect(Rails.logger).to receive(:info).with("Created school: 567890 - Test Independent School")
        expect(Rails.logger).to receive(:info).with("Created school: 999888 - School With Lead Partner")
        expect(Rails.logger).to receive(:info).with("Deleted school: 987645 - Removed from GIAS School")

        expect(Rails.logger).to receive(:info).with("Processed 7. Kept 6. Filtered out: 1")

        subject
      end
    end

    context "lead partner realignment" do
      let!(:school_with_lead_partner) { create(:school, urn: "999888", name: "School With Lead Partner") }
      let!(:lead_partner) { create(:lead_partner, :school, school: school_with_lead_partner, name: "Old Lead Partner Name") }

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

    context "fail fast behaviour" do
      context "when individual school import fails" do
        let(:invalid_csv_content) do
          <<~CSV
            URN,EstablishmentName,TypeOfEstablishment (code),Postcode,Town,Address3,Locality,OpenDate
            123456,Test Primary School,1,AB1 2CD,TestTown,,,2020-01-01
            234567,,1,EF3 4GH,TestCity,,,2019-05-15
            345678,Test Secondary School,15,IJ5 6KL,,TestVillage,,
          CSV
        end

        it "fails the entire import immediately" do
          expect { described_class.call(csv_content: invalid_csv_content, download_record: download_record) }
            .to raise_error(ActiveRecord::RecordInvalid)
        end
      end
    end

    context "date parsing" do
      let(:date_csv_content) do
        <<~CSV
          URN,EstablishmentName,TypeOfEstablishment (code),Postcode,Town,Address3,Locality,OpenDate
          111111,Valid Date School,1,AB1 2CD,TestTown,,,2020-01-01
          222222,Invalid Date School,1,EF3 4GH,TestCity,,,not-a-date
          333333,Blank Date School,1,IJ5 6KL,TestVillage,,,
        CSV
      end

      it "parses valid dates correctly" do
        described_class.call(csv_content: date_csv_content, download_record: download_record)

        school = School.find_by(urn: "111111")
        expect(school.open_date).to eq(Date.parse("2020-01-01"))
      end

      it "handles invalid dates gracefully" do
        expect(Rails.logger).to receive(:warn).with("Failed to parse date: not-a-date")

        described_class.call(csv_content: date_csv_content, download_record: download_record)

        school = School.find_by(urn: "222222")
        expect(school.open_date).to be_nil
      end

      it "handles blank dates" do
        described_class.call(csv_content: date_csv_content, download_record: download_record)

        school = School.find_by(urn: "333333")
        expect(school.open_date).to be_nil
      end
    end
  end
end
