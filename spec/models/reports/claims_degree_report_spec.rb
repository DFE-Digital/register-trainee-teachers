# frozen_string_literal: true

require "rails_helper"

describe Reports::ClaimsDegreeReport do
  let(:generated_csv) do
    CSV.generate do |csv|
      described_class.new(csv, scope: degrees).generate_report
    end
  end

  describe "#generate_report" do
    context "with no degrees" do
      let(:degrees) { Degree.none }

      it "generates a CSV with correct headers and no data rows" do
        lines = generated_csv.split("\n")
        expect(lines.first).to eq("trn,date_of_birth,nino,subject_code,description")
        expect(lines.count).to eq(1)
      end
    end

    context "with degrees" do
      let(:trainee) { create(:trainee, :trn_received, :with_degree, :with_hesa_trainee_detail) }
      let(:degrees) { Degree.where(trainee:) }

      it "generates CSV with correct headers" do
        expect(generated_csv).to include("trn,date_of_birth,nino,subject_code,description")
      end

      it "includes all trainee and degree data" do
        degree = trainee.degrees.first

        expect(generated_csv).to include(trainee.trn)
        expect(generated_csv).to include(trainee.date_of_birth.iso8601)
        expect(generated_csv).to include(trainee.hesa_trainee_detail.ni_number)
        expect(generated_csv).to include(degree.subject)
      end
    end
  end
end
