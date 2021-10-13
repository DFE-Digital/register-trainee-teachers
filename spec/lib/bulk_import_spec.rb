# frozen_string_literal: true

require "rails_helper"

describe BulkImport do
  include SeedHelper

  let(:provider) { create(:provider) }
  let(:trainee) { build(:trainee) }

  describe ".import_row" do
    let(:csv_row) do
      {
        "Route" => "School Direct Salaried PG)",
        "Course start date" => "13/04/1992",
        "ITT Subject 1" => "English",
        "Degree type" => "Bachelor of Arts",
        "Institution" => "Durham University",
        "Degree subject" => "Cardiology",
        "Degree grade" => "First-class Honours",
        "Subject of UG. Degree (Non UK)" => "",
      }
    end

    subject { described_class.import_row(provider, csv_row) }

    it "creates the trainee/degree" do
      expect { subject }.to change { Trainee.count }.from(0).to(1)
    end

    context "with Institution 2 provided" do
      before do
        csv_row.merge!("Institution 2" => "University of Plymouth")
      end

      it "creates two degrees" do
        expect { subject }.to change { Degree.count }.from(0).to(2)
      end
    end

    context "with Country (Non UK) degree" do
      before do
        csv_row.merge!("Country (Non UK) degree" => "Japan", "Country (Non UK) degree 2" => "Brazil")
      end

      it "creates a non-uk degree" do
        expect { subject }.to change { Degree.non_uk.count }.from(0).to(2)
      end
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

  describe ".to_post_code" do
    let(:postcode) { "NE29 9LH" }

    subject { described_class.to_post_code(postcode) }

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

  describe ".to_ethnic_group" do
    let(:trainee) { create(:trainee, :school_direct_salaried) }
    let(:ethnicity) { "Another ethnic group\n(includes any other ethnic group, for example, Arab)" }

    subject { described_class.to_ethnic_group(ethnicity) }

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

      it "returns nil" do
        expect(subject).to be_nil
      end
    end
  end

  describe ".build_uk_degree" do
    subject do
      described_class.build_uk_degree(trainee,
                                      degree_type: "Master of Music",
                                      grade: "Pass",
                                      institution: "University of Central Lancashire",
                                      graduation_year: "2021",
                                      subject: "Volcanology")
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

  describe ".build_non_uk_degree" do
    subject do
      described_class.build_non_uk_degree(trainee,
                                          country: "France",
                                          non_uk_degree: "Bachelor degree",
                                          subject: "Combined Studies",
                                          graduation_year: "2021")
    end

    it "builds a non_uk degree" do
      expect(subject.locale_code).to eq "non_uk"
      expect(subject.trainee).to eq trainee
      expect(subject.non_uk_degree).to eq "Bachelor degree"
      expect(subject.graduation_year).to eq 2021
      expect(subject.subject).to eq "Combined Studies"
      expect(subject.country).to eq "France"
    end
  end

  describe ".to_disability_ids" do
    subject { described_class.to_disability_ids(disabilities) }

    context "when disabilities are provided" do
      let(:disabilities) { "learninG DifFiCulty" }

      before do
        generate_seed_disabilities
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

  describe ".to_school_id" do
    subject { described_class.to_school_id(school_name) }

    let(:school_name) { "Primrose Hill School" }

    context "when the school exists" do
      let!(:school) { create(:school, name: "Primrose Hill School") }

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

  describe ".set_nationalities" do
    subject { described_class.set_nationalities(trainee, csv_row) }

    context "when nationalities exist" do
      let(:csv_row) do
        {
          "Nationality" => "british",
          "Nationality (other)" => "albanian",
        }
      end

      before { generate_seed_nationalities }

      it "sets nationalities against the trainee" do
        subject
        expect(trainee.nationality_ids).to match_array(Nationality.where(name: %w[british albanian]).ids)
      end
    end

    context "when nationalities are not present" do
      let(:csv_row) do
        {
          "Nationality" => "",
          "Nationality (other)" => "",
        }
      end

      it "returns a blank array" do
        subject
        expect(trainee.nationality_ids).to be_empty
      end
    end
  end

  describe ".set_course" do
    let(:csv_row) do
      {
        "Course code" => "1CS",
      }
    end

    subject { described_class.set_course(provider, trainee, csv_row) }

    context "a course can be found" do
      let!(:course) { create(:course, provider: provider, code: "1CS", level: :secondary, study_mode: :full_time) }

      it "sets the course code on the trainee" do
        subject
        expect(trainee.course_code).to eq("1CS")
        expect(trainee.study_mode).to eq("full_time")
      end
    end

    context "with a part/full time course" do
      let!(:course) { create(:course, provider: provider, code: "1CS", study_mode: :full_time_or_part_time) }

      it "does not set the study_mode on the trainee" do
        subject
        expect(trainee.course_code).to eq("1CS")
        expect(trainee.study_mode).to be_nil
      end
    end

    context "a course subject can't be found" do
      it "does not set the course_code on the trainee" do
        subject
        expect(trainee.course_code).to be_nil
      end
    end
  end

  describe ".to_course_subject" do
    subject { described_class.to_course_subject(itt_subject) }

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

  describe ".to_degree_grade" do
    subject { described_class.to_degree_grade(degree_grade) }

    context "a degree grade can be found" do
      let(:degree_grade) { "First-class honours" }

      it "returns it" do
        expect(subject).to eq("First-class honours")
      end
    end

    context "a degree grade can't be found" do
      let(:degree_grade) { "Summa Cum Laude" }

      it "raises an error" do
        expect { subject }.to raise_error(having_attributes(message: "Degree grade not recognised: Summa Cum Laude"))
      end
    end
  end

  describe ".validate_uk_degree" do
    subject { described_class.validate_uk_degree(degree_type) }

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

  describe ".validate_degree_institution" do
    subject { described_class.validate_degree_institution(degree_institution) }

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

  describe ".validate_degree_subject" do
    subject { described_class.validate_degree_subject(degree_subject) }

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

    context "with no value provided" do
      let(:degree_subject) { " " }

      it "returns nil" do
        expect(subject).to be_nil
      end
    end
  end

  describe ".validate_enic_non_uk" do
    subject { described_class.validate_enic_non_uk_degree(enic) }

    context "the enic value can be found" do
      let(:enic) {  "Bachelor degree" }

      it "returns it" do
        expect(subject).to eq "Bachelor degree"
      end
    end

    context "the enic value can't be found" do
      let(:enic) { "Phd" }

      it "returns nil" do
        expect(subject).to be_nil
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
