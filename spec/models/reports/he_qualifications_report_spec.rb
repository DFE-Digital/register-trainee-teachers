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
      multi_subject_trainee = create(:trainee, :trn_received, :with_hesa_trainee_detail)
      create(:degree, :uk_degree_with_details, trainee: multi_subject_trainee, subject_uuid: "54dc5ee9-3397-4615-b4cd-0a2ad1c2ac60")
      @trainees << multi_subject_trainee

      report = described_class.new(CSV.new(csv), scope: qualifications)
      report.generate_report
    end

    it "generates a CSV with the correct headers" do
      expect(csv.string).to include("trn,date_of_birth,nino,subject_code,description\n")
    end

    it "outputs one row for each qualification" do
      qualifications.each do |degree|
        top_level_degree_subject = DfEReference::DegreesQuery::SUBJECTS.one(degree.subject_uuid)

        degree_subjects =
          if top_level_degree_subject&.hecos_code.present?
            [top_level_degree_subject]
          elsif top_level_degree_subject&.subject_ids.present?
            top_level_degree_subject.subject_ids.map do |subject_id|
              DfEReference::DegreesQuery::SUBJECTS.one(subject_id)
            end.compact
          else
            []
          end

        degree_subjects.each do |degree_subject|
          expect(csv.string).to include(
            "#{degree.trainee.trn},#{degree.trainee.date_of_birth.iso8601},#{degree.trainee.hesa_trainee_detail.ni_number},#{degree_subject.hecos_code},#{CsvValueSanitiser.new(degree_subject.name).sanitise}\n",
          )
        end
      end
    end
  end
end
