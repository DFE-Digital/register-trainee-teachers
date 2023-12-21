# frozen_string_literal: true

require "rails_helper"

module Degrees
  describe CreateFromCsvRow do
    subject(:service) { described_class.call(trainee:, csv_row:) }

    let(:trainee) { create(:trainee) }
    let(:degree) { trainee.degrees.first }
    let(:csv_row) do
      CSV.read(
        file_fixture("hpitt_degree_import.csv").to_path,
        headers: true,
        encoding: "ISO-8859-1",
        header_converters: ->(f) { f&.strip },
      ).first
    end

    describe "#call" do
      it "attaches a degree to the trainee" do
        service
        expect(degree.subject).to eql "Philosophy"
      end

      context "with \"other\" degree grade" do
        let(:csv_row) do
          {
            "Provider trainee ID" => "A2",
            "Region" => "London",
            "First names" => "Adam",
            "Middle names" => nil,
            "Last names" => "Test",
            "Date of birth" => "21/09/1997",
            "Sex" => "Male",
            "Nationality" => "british",
            "UK address: Line 1" => "99 Lovely Road",
            "UK address: Line 2" => nil,
            "UK address: town or city" => "Oxford",
            "UK Address 1: Postcode" => "OX41RG",
            "Outside UK address" => nil,
            "Email" => "adam.test@gmail.com",
            "Ethnicity" => "White - English, Scottish, Welsh, Northern Irish or British",
            "Disabilities" => "Not provided",
            "Course level" => nil,
            "Course education phase" => "Secondary",
            "Course age range" => "11 to 16",
            "Course ITT subject 1" => "Mathematics",
            "Course ITT subject 2" => nil,
            "Course ITT Subject 3" => nil,
            "Course study mode" => "full-time",
            "Course ITT start date" => "2022-09-09",
            "Course Expected End Date" => "31/07/2023",
            "Trainee start date" => "09/09/2022",
            "Employing school URN" => "131609",
            "Degree: country" => "United Kingdom",
            "Degree: subjects" => "Philosophy, Politics, Economics",
            "Degree: UK degree types" => "Bachelor of Arts",
            "Degree: UK awarding institution" => "University of Oxford",
            "Degree: UK grade" => "Other: Diploma of Higher Education",
            "Degree: Non-UK degree types" => nil, "Degree: graduation year" => "2018"
          }
        end

        it "saves the other degree grade" do
          service
          expect(degree.other_grade).to eql "Diploma of Higher Education"
        end
      end
    end
  end
end
