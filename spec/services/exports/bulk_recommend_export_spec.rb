# frozen_string_literal: true

require "rails_helper"

describe Exports::BulkRecommendExport, type: :model do
  describe "#call" do
    subject(:service) { described_class.call(trainees) }

    let(:trainee) { create(:trainee, :bulk_recommend_from_hesa) }
    let(:csv) { CSV.parse(service, headers: true) }
    let(:relevent_trainee_count) { Trainee.count }
    let(:trainee_csv_row) { csv[1] }
    let(:trainees) do
      trainee
      Trainee.all
    end

    let(:expected_headers) do
      [
        "TRN",
        "Provider trainee ID",
        "HESA ID",
        "Last names",
        "First names",
        "Lead partner",
        "QTS or EYTS",
        "Route",
        "Phase",
        "Age range",
        "Subject",
        "Date QTS or EYTS requirement met",
      ]
    end

    context "when generated" do
      it "includes a heading row and all relevant Trainees in the CSV file" do
        line_count = csv.size - 1 # bulk QTS has an extra row for the "do not edit" row
        expect(line_count).to eq(relevent_trainee_count)
      end

      context "when a trainees have no HESA id's" do
        let(:expected_headers) do
          [
            "TRN",
            "Provider trainee ID",
            "Last names",
            "First names",
            "Lead partner",
            "QTS or EYTS",
            "Route",
            "Phase",
            "Age range",
            "Subject",
            "Date QTS or EYTS requirement met",
          ]
        end

        let(:trainee) { create(:trainee, :bulk_recommend) }

        it "includes the correct headers" do
          expect(csv.headers).to match_array(expected_headers)
        end
      end

      it "includes the correct headers" do
        expect(csv.headers).to match_array(expected_headers)
      end
    end

    context "when there are trainees with HESA IDs" do
      let(:trainee_report) { Reports::TraineeReport.new(trainee) }

      it "includes the trn in the csv" do
        expect(trainee_csv_row["TRN"]).to eq(trainee_report.trn)
      end

      it "includes the provider trainee id" do
        expect(trainee_csv_row["Provider trainee ID"]).to end_with(trainee_report.provider_trainee_id)
      end

      it "includes the HESA ID" do
        expect(trainee_csv_row["HESA ID"]).to eq(trainee_report.hesa_id)
      end

      it "includes the Last names" do
        expect(trainee_csv_row["Last names"]).to eq(trainee_report.last_names)
      end

      it "includes the first names" do
        expect(trainee_csv_row["First names"]).to eq(trainee_report.first_names)
      end

      it "includes the lead partner" do
        expect(trainee_csv_row["Lead partner"]).to eq(trainee_report.lead_partner_name)
      end

      it "includes the QTS or EYTS" do
        expect(trainee_csv_row["QTS or EYTS"]).to eq(trainee_report.qts_or_eyts)
      end

      it "includes the course training route" do
        expect(trainee_csv_row["Route"]).to eq(trainee_report.course_training_route)
      end

      it "includes the Phase" do
        expect(trainee_csv_row["Phase"]).to eq(trainee_report.course_education_phase)
      end

      it "includes the Age range" do
        expect(trainee_csv_row["Age range"]).to eq(trainee_report.course_age_range)
      end

      it "includes the Subject" do
        expect(trainee_csv_row["Subject"]).to eq(trainee_report.subjects)
      end
    end
  end
end
