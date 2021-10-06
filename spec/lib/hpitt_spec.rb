# frozen_string_literal: true

require "rails_helper"

describe HPITT do
  include SeedHelper

  describe "#import_row" do
    let!(:provider) { create(:provider, :teach_first) }

    let(:csv_row) do
      {
        "Course start date" => "13/04/1992",
        "ITT Subject 1" => "English",
        "Degree type" => "Bachelor of Arts",
        "Institution" => "Durham University",
        "Degree subject" => "Cardiology",
        "Degree grade" => "First-class Honours",
        "Subject of UG. Degree (Non UK)" => "",
      }
    end

    subject { HPITT.import_row(csv_row) }

    it "creates the trainee/degree" do
      expect { subject }.to change { Trainee.count }.from(0).to(1)
    end

    context "when Outside UK address is provided" do
      before do
        csv_row.merge!("Postal code" => "100100", "Outside UK address" => "Around the world")
      end

      it "sets the locale_code to non-uk" do
        subject
        trainee = Trainee.last
        expect(trainee.locale_code).to eq("non_uk")
        expect(trainee.postcode).to be_nil
      end
    end
  end

  describe "#to_post_code" do
    let(:postcode) { "NE29 9LH" }

    subject { HPITT.to_post_code(postcode) }

    it "returns the post code" do
      expect(subject).to eq "NE29 9LH"
    end

    context "with missing whitespace" do
      let(:ethnicity) { "NE299LH." }

      it "returns the normalised form" do
        expect(subject).to eq "NE29 9LH"
      end
    end
  end

  describe "#to_ethnic_group" do
    let(:trainee) { create(:trainee, :school_direct_salaried) }
    let(:ethnicity) { "Another ethnic group\n(includes any other ethnic group, for example, Arab)" }

    subject { HPITT.to_ethnic_group(ethnicity) }

    it "returns the correct ethnic group" do
      expect(subject).to eq Diversities::ETHNIC_GROUP_ENUMS[:other]
    end

    context "with a normalised form" do
      let(:ethnicity) { "anotherethnicgroupincludesanyotherethnicgroupforexamplearab" }

      it "returns the correct ethnic group" do
        expect(subject).to eq Diversities::ETHNIC_GROUP_ENUMS[:other]
      end
    end

    context "when the ethnic group cannot be mapped" do
      let(:ethnicity) { "ethnic group" }

      it "raises an error" do
        expect { subject }.to raise_error(having_attributes(message: "Ethnic group not recognised: ethnic group"))
      end
    end
  end

  describe "build_degree" do
    subject { HPITT.build_degree(trainee, csv_row) }

    let(:trainee) { build(:trainee) }

    context "when the degree country row is blank" do
      let(:csv_row) do
        {
          "Degree type" => "Master of Music",
          "Degree grade" => "Pass",
          "Graduation year" => 2021,
          "Institution" => "University of Central Lancashire",
          "Degree subject" => "Volcanology",
        }
      end

      it "builds a uk degree" do
        expect(subject.locale_code).to eq "uk"
        expect(subject.trainee).to eq trainee
        expect(subject.uk_degree).to eq "Master of Music"
        expect(subject.grade).to eq "Pass"
        expect(subject.graduation_year).to eq 2021
        expect(subject.institution).to eq "The University of Central Lancashire"
        expect(subject.subject).to eq "Volcanology"
      end
    end

    context "when the degree country row is not blank" do
      let(:csv_row) do
        {
          "Country (Non UK) degree" => "France",
          "UK ENIC equivalent (Non UK)" => "Bachelor degree",
          "Undergrad degree date obtained (Non UK)" => "2021",
          "Subject of UG. Degree (Non UK)" => "Volcanology",
        }
      end

      it "builds a non_uk degree" do
        expect(subject.locale_code).to eq "non_uk"
        expect(subject.trainee).to eq trainee
        expect(subject.non_uk_degree).to eq "Bachelor degree"
        expect(subject.graduation_year).to eq 2021
        expect(subject.subject).to eq "Volcanology"
        expect(subject.country).to eq "France"
      end
    end
  end

  describe "to_age_range" do
    subject { HPITT.to_age_range(age_range) }

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

  describe "to_disability_ids" do
    subject { HPITT.to_disability_ids(disabilities) }

    context "when disabilities exist" do
      let(:disabilities) { "Learning difficulty\n(for example, dyslexia, dyspraxia or ADHD)" }

      before do
        generate_seed_diversities
      end

      it "is returned" do
        expect(subject).to match_array(Disability.where(name: "Learning difficulty").ids)
      end
    end

    context "when disabilities are not present" do
      let(:disabilities) { nil }

      it "returns a blank array" do
        expect(subject).to eq([])
      end
    end
  end

  describe "to_school_id" do
    subject { HPITT.to_school_id(urn) }

    let(:urn) { "123" }

    context "when the school exists" do
      let!(:school) { create(:school, urn: 123) }

      it "returns the school id" do
        expect(subject).to eq(school.id)
      end
    end

    context "when thes school is not present" do
      it "returns nil" do
        expect(subject).to eq(nil)
      end
    end
  end

  describe "#to_nationality_ids" do
    subject { HPITT.to_nationality_ids(nationalities) }

    context "when nationalities exist" do
      let(:nationalities) { "albanian" }

      before { generate_seed_nationalities }

      it "is returned" do
        expect(subject).to match_array(Nationality.where(name: %w[albanian]).ids)
      end
    end

    context "when nationalities are not present" do
      let(:nationalities) { nil }

      it "returns a blank array" do
        expect(subject).to eq([])
      end
    end
  end

  describe "to_course_subject" do
    subject { HPITT.to_course_subject(itt_subject) }

    context "a course subject can be found" do
      let(:itt_subject) { "Design and Technology" }

      it "returns it" do
        expect(subject).to eq("Design and technology")
      end
    end

    context "a course subject can't be found" do
      let(:itt_subject) { "Design" }

      it "raises an error" do
        expect { subject }.to raise_error(having_attributes(message: "Course subject not recognised: Design"))
      end
    end
  end

  describe "to_degree_grade" do
    subject { HPITT.to_degree_grade(degree_grade) }

    context "a degree grade can be found" do
      let(:degree_grade) { "First-class honours" }

      it "returns it" do
        expect(subject).to eq("First-class honours")
      end
    end

    context "a degree grade can't be found" do
      let(:degree_grade) { "Summa Cum Laude" }

      it "raises an error" do
        expect { subject }.to raise_error(having_attributes(message: "Degree grade not recognised"))
      end
    end
  end

  describe "validate_uk_degree" do
    subject { HPITT.validate_uk_degree(degree_type) }

    context "the degree type can be found" do
      let(:degree_type) { "Doctor of Divinity" }

      it "returns it" do
        expect(subject).to eq "Doctor of Divinity"
      end
    end

    context "the degree type can't be found" do
      let(:degree_type) { "Master of the universe" }

      it "raises an error" do
        expect { subject }.to raise_error "Degree type not recognised: Master of the universe"
      end
    end

    context "with a degree_type abbreviation" do
      let(:degree_type) { "DD" }

      it "returns the degree type" do
        expect(subject).to eq "Doctor of Divinity"
      end
    end

    context "with extra whitespace" do
      let(:degree_type) { " Doctor  of  Divinity  " }

      it "returns the degree type" do
        expect(subject).to eq "Doctor of Divinity"
      end
    end
  end

  describe "#validate_degree_institution" do
    subject { HPITT.validate_degree_institution(degree_institution) }

    context "when an exact match is found" do
      let(:degree_institution) { "The University of Manchester" }

      it "returns the degree institution" do
        expect(subject).to eq "The University of Manchester"
      end
    end

    context "when it can't be found" do
      let(:degree_institution) { "University city" }

      it "returns other uk" do
        expect(subject).to eq "Other UK"
      end
    end

    context "with a mapped degree institution" do
      let(:degree_institution) { "Durham University" }

      it "returns the degree institution" do
        expect(subject).to eq "University of Durham"
      end
    end

    context "with extra text in parantheses" do
      let(:degree_institution) { "University of Suffolk (Formerly University Campus Suffolk)" }

      it "returns the degree institution" do
        expect(subject).to eq "University Campus Suffolk"
      end
    end
  end

  describe "validate_degree_subject" do
    subject { HPITT.validate_degree_subject(degree_subject) }

    context "the degree subejct can be found" do
      let(:degree_subject) { "Bob Dylan Studies" }

      it "returns it" do
        expect(subject).to eq "Bob Dylan Studies"
      end
    end

    context "the degree subject can't be found" do
      let(:degree_subject) { "Astrology" }

      it "raises an error" do
        expect { subject }.to raise_error "Degree subject not recognised: Astrology"
      end
    end

    context "with extra whitespace" do
      let(:degree_subject) { " Bob  Dylan  Studies  " }

      it "returns the degree subject" do
        expect(subject).to eq "Bob Dylan Studies"
      end
    end
  end

  describe "validate_enic_non_uk" do
    subject { HPITT.validate_enic_non_uk_degree(enic) }

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

    context "with a blank value" do
      let(:enic) {  "" }

      it "returns NON_ENIC" do
        expect(subject).to eq(NON_ENIC)
      end
    end
  end
end
