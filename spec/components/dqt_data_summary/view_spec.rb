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
          "qualified_teacher_status" => nil,
          "induction" => nil,
          "initial_teacher_training" => nil,
          "qualifications" => [],
          "name" => "Abigail McPhillips",
          "dob" => "1990-04-27T00:00:00",
        }
      end

      before do
        render_inline(described_class.new(dqt_data:))
      end

      it "renders 'Data not available' content" do
        expect(rendered_component).to have_text("No data")
      end
    end

    context "when there is data" do
      let(:dqt_data) do
        {
          "trn" => "1234567",
          "qualified_teacher_status" => {
            "name" => "Trainee Teacher",
            "state" => "Active",
            "state_name" => "Active",
            "qts_date" => nil,
          },
          "induction" => nil,
          "initial_teacher_training" => {
            "state" => "Active",
            "state_code" => "Active",
            "programme_start_date" => "2022-09-19T00:00:00Z",
            "programme_end_date" => "2026-05-22T00:00:00Z",
            "programme_type" => "Provider-led (undergrad)",
            "result" => "In Training",
            "subject1" => "primary teaching",
            "qualification" => "BA (Hons)",
            "subject1_code" => "100511",
          },
          "qualifications" => [
            {
              "name" => "Higher Education",
              "he_qualification_name" => "First Degree",
            },
          ],
          "name" => "Abigail McPhillips",
          "dob" => "1990-04-27T00:00:00",
        }
      end

      before do
        render_inline(described_class.new(dqt_data:))
      end

      it "renders the data" do
        expect(rendered_component).to have_text("Abigail McPhillips")
        expect(rendered_component).to have_text("No data")
        expect(rendered_component).to have_text("In Training")
        expect(rendered_component).to have_text("First Degree")
      end
    end
  end
end
