# frozen_string_literal: true

require "rails_helper"

module TrsDataSummary
  describe View, type: :component do
    let(:trs_data) do
      {
        "trn" => "1234567",
        "firstName" => "John",
        "lastName" => "Doe",
        "dateOfBirth" => "1990-01-01",
        "qts" => {
          "holdsFrom" => "2020-01-01",
          "routes" => [
            {
              "routeToProfessionalStatusType" => {
                "routeToProfessionalStatusTypeId" => "6bd6332b-f799-4234-a67d-84643dbfd6cc",
                "name" => "Assessment Only",
                "professionalStatusType" => "QualifiedTeacherStatus",
              },
            },
          ],
        },
        "initialTeacherTraining" => [
          {
            "provider" => {
              "name" => "Test University",
              "ukprn" => "12345",
            },
            "qualification" => {
              "name" => "PGCE with QTS",
            },
            "startDate" => {
              "hasValue" => true,
              "value" => "2019-09-01",
            },
            "endDate" => {
              "hasValue" => true,
              "value" => "2020-06-30",
            },
            "programmeType" => {
              "hasValue" => true,
              "value" => "School Direct (salaried)",
            },
            "programmeTypeDescription" => "School Direct Training Programme Salaried",
            "result" => {
              "hasValue" => true,
              "value" => "Pass",
            },
            "ageRange" => {
              "description" => "5-11",
            },
            "subjects" => [
              {
                "code" => "100366",
                "name" => "Primary",
              },
            ],
          },
        ],
      }
    end

    context "with TRS data" do
      before do
        render_inline(described_class.new(trs_data:))
      end

      it "displays general data" do
        {
          "trn" => "1234567",
          "firstName" => "John",
          "lastName" => "Doe",
        }.each do |field, value|
          expect(rendered_content).to include(field)
          expect(rendered_content).to include(value)
        end
      end

      it "displays nested data" do
        {
          "qts.holdsFrom" => "2020-01-01",
          "qts.route1.routeToProfessionalStatusTypeId" => "6bd6332b-f799-4234-a67d-84643dbfd6cc",
          "qts.route1.name" => "Assessment Only",
          "qts.route1.professionalStatusType" => "QualifiedTeacherStatus",
        }.each do |field, value|
          expect(rendered_content).to include(field)
          expect(rendered_content).to include(value)
        end
      end

      it "displays training instances" do
        expect(rendered_content).to include("Training instance 1")

        {
          "provider" => "Test University",
          "programmeType" => "School Direct (salaried)",
          "subject1" => "Primary (100366)",
        }.each do |field, value|
          expect(rendered_content).to include(field)
          expect(rendered_content).to include(value)
        end
      end
    end

    context "without TRS data" do
      before do
        render_inline(described_class.new(trs_data: nil))
      end

      it "displays an appropriate message" do
        expect(rendered_content).to include("Data not available")
      end
    end
  end
end
