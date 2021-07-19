# frozen_string_literal: true

require "rails_helper"

describe Hoppit do
  describe "find_course" do
    let(:trainee) { create(:trainee, :school_direct_salaried) }
    let(:csv_row) do
      {
        "Duration" => "1 year",
        "Course start date" => "13/04/1992",
        "ITT Subject 1" => "English",
      }
    end

    subject { Hoppit.find_course(trainee, csv_row) }

    context "if a course can't be found" do
      it "raises an error" do
        expect { subject }.to raise_error(having_attributes(message: "No course found"))
      end
    end

    context "if 1 course is found" do
      let!(:course) do
        create(
          :course,
          accredited_body_code: trainee.provider.code,
          duration_in_years: 1,
          start_date: Date.parse("13/04/1992"),
          name: "English",
          route: trainee.training_route,
        )
      end

      it "returns the course" do
        expect(subject).to eq course
      end
    end

    context "if multiple courses are found" do
      let!(:courses) do
        create_list(
          :course,
          2,
          accredited_body_code: trainee.provider.code,
          duration_in_years: 1,
          start_date: Date.parse("13/04/1992"),
          name: "English",
          route: trainee.training_route,
        )
      end

      it "raises an error" do
        expect { subject }.to raise_error(having_attributes(message: "Course ambiguous, multiple found"))
      end
    end
  end

  describe "to_age_range" do
    subject { Hoppit.to_age_range(age_range) }

    context "an age rage can be found" do
      let(:age_range) { "Other 5-14 programme" }

      it "is returned" do
        expect(subject).to eq [5, 14]
      end
    end

    context "an age rage can't be found" do
      let(:age_range) { "34-97 programme" }

      it "raises an error" do
        expect { subject }.to raise_error(having_attributes(message: "Course age range not recognised"))
      end
    end
  end

  describe "to_degree_grade" do
    subject { Hoppit.to_degree_grade(degree_grade) }

    context "a degree grade can be found" do
      let(:degree_grade) { "First-class honours" }

      it "returns it" do
        expect(subject).to eq("First-class Honours")
      end
    end

    context "a degree grade can't be found" do
      let(:degree_grade) { "Summa Cum Laude" }

      it "raises an error" do
        expect { subject }.to raise_error(having_attributes(message: "Degree grade not recognised"))
      end
    end
  end

  describe "to_training_route" do
    subject { Hoppit.to_training_route(training_route) }

    context "a training route can be found" do
      let(:training_route) { "Early years (undergrad)" }

      it "returns it" do
        expect(subject).to eq("early_years_undergrad")
      end
    end

    context "a training route can't be found" do
      let(:training_route) { "Very Early years (undergrad)" }

      it "raises an error" do
        expect { subject }.to raise_error(having_attributes(message: "Training route not recognised"))
      end
    end
  end

  describe "validate_uk_degree" do
    subject { Hoppit.validate_uk_degree(degree_type) }

    context "the degree type can be found" do
      let(:degree_type) { "Doctor of Divinity" }

      it "returns it" do
        expect(subject).to eq "Doctor of Divinity"
      end
    end

    context "the degree type can't be found" do
      let(:degree_type) { "Master of the universe" }

      it "raises an error" do
        expect { subject }.to raise_error "Degree type not recognised"
      end
    end
  end

  describe "validate_degree_subject" do
    subject { Hoppit.validate_degree_subject(degree_subject) }

    context "the degree subejct can be found" do
      let(:degree_subject) { "Bob Dylan Studies" }

      it "returns it" do
        expect(subject).to eq "Bob Dylan Studies"
      end
    end

    context "the degree subject can't be found" do
      let(:degree_subject) { "Astrology" }

      it "raises an error" do
        expect { subject }.to raise_error "Degree subject not recognised"
      end
    end
  end

  describe "validate_enic_non_uk" do
    subject { Hoppit.validate_enic_non_uk_degree(enic) }

    context "the enic value can be found" do
      let(:enic) {  "Bachelor degree" }

      it "returns it" do
        expect(subject).to eq "Bachelor degree"
      end
    end

    context "the enic value can't be found" do
      let(:enic) {  "Phd" }

      it "raises an error" do
        expect { subject }.to raise_error "ENIC equivalent not recognised"
      end
    end
  end
end
