# frozen_string_literal: true

require "rails_helper"

describe Reports::HeQualificationsReport do
  let(:csv) { StringIO.new }

  context "given an empty list of qualifications" do
    let(:qualifications) { [] }

    before do
      report = described_class.new(CSV.new(csv), scope: qualifications)
      report.generate_report
    end

    it "generates a CSV with the correct headers and no rows" do
      expect(csv.string).to include("trn,date_of_birth,nino,subject_code,description\n")
    end
  end

  context "given a list of qualifications" do
    let(:qualifications) { Degree.all }

    before do
      @trainees = create_list(:trainee, 3, :trn_received, :with_hesa_trainee_detail)
      @trainees.each_with_index do |trainee, index|
        create_list(:degree, index + 1, :uk_degree_with_details, trainee:)
      end

      report = described_class.new(CSV.new(csv), scope: qualifications)
      report.generate_report
    end

    it "generates a CSV with the correct headers" do
      expect(csv.string).to include("trn,date_of_birth,nino,subject_code,description\n")
    end

    it "outputs one row for each qualification" do
      qualifications.each do |degree|
        degree_subject = DfEReference::DegreesQuery::SUBJECTS.one(degree.subject_uuid)
        expect(csv.string).to include(
          "#{degree.trainee.trn},#{degree.trainee.date_of_birth.iso8601},#{degree.trainee.hesa_trainee_detail.ni_number},#{degree_subject.hecos_code},#{CsvValueSanitiser.new(degree_subject.name).sanitise}\n",
        )
      end
    end
  end
end
