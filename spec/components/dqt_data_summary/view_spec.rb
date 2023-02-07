# frozen_string_literal: true

require "rails_helper"

module DqtDataSummary
  describe View, type: :component do
    context "when there is no data" do
      before do
        render_inline(described_class.new(dqt_data: nil))
      end

      it "renders 'Data not available' content" do
        expect(rendered_component).to have_text("Data not available")
      end
    end

    context "when there is some missing data" do
      let(:dqt_data) do
        {
          "trn" => "1234567",
          "firstName" => "Abigail",
          "lastName" => "McPhillips",
          "dateOfBirth" => "1977-07-17",
          "nationalInsuranceNumber" => "098765",
          "hasActiveSanctions" => false,
          "qtsDate" => "2022-07-18",
          "eytsDate" => nil,
          "earlyYearsStatus" => nil,
          "initialTeacherTraining" => nil,
        }
      end

      before do
        render_inline(described_class.new(dqt_data:))
      end

      it "renders available data" do
        expect(rendered_component).to have_text("Abigail")
        expect(rendered_component).to have_text("McPhillips")
      end
    end

    context "when there is data" do
      let(:dqt_data) do
        {
          "trn" => "1234567",
          "firstName" => "Abigail",
          "lastName" => "McPhillips",
          "dateOfBirth" => "1977-07-17",
          "nationalInsuranceNumber" => "098765",
          "hasActiveSanctions" => false,
          "qtsDate" => "2022-07-18",
          "eytsDate" => nil,
          "earlyYearsStatus" => nil,
          "initialTeacherTraining" => [
            {
              "programmeStartDate" => "2021-09-06",
              "programmeEndDate" => "2022-06-17",
              "programmeType" => "SchoolDirecttrainingprogramme",
              "result" => "Pass",
              "provider" => { "ukprn" => "10034789" },
            },
          ],
        }
      end

      before do
        render_inline(described_class.new(dqt_data:))
      end

      it "renders the data" do
        expect(rendered_component).to have_text("Abigail")
        expect(rendered_component).to have_text("McPhillips")
        expect(rendered_component).to have_text("Pass")
      end
    end

    context "when there are multiple training instances" do
      let(:dqt_data) do
        {
          "trn" => "1234567",
          "firstName" => "Abigail",
          "lastName" => "McPhillips",
          "dateOfBirth" => "1977-07-17",
          "nationalInsuranceNumber" => "098765",
          "hasActiveSanctions" => false,
          "qtsDate" => "2022-07-18",
          "eytsDate" => nil,
          "earlyYearsStatus" => nil,
          "initialTeacherTraining" => [
            {
              "programmeStartDate" => "2021-09-06",
              "programmeEndDate" => "2022-06-17",
              "programmeType" => "SchoolDirecttrainingprogramme",
              "result" => "Pass",
              "provider" => { "ukprn" => "10034789" },
            },
            {
              "programmeStartDate" => "2021-09-06",
              "programmeEndDate" => "2022-06-17",
              "programmeType" => "SchoolDirecttrainingprogramme",
              "result" => "Pass",
              "provider" => { "ukprn" => "10034789" },
            },
          ],
        }
      end

      before do
        render_inline(described_class.new(dqt_data:))
      end

      it "renders them all" do
        expect(rendered_component).to have_text("Training instance 1")
        expect(rendered_component).to have_text("Training instance 2")
      end
    end
  end
end
