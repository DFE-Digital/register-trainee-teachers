# frozen_string_literal: true

require "rails_helper"

module Hpitt
  describe ImportTrainee do
    include SeedHelper

    let!(:provider) { create(:provider, :teach_first) }
    let(:csv_row) {
      {
        "ITT start date" => "13/04/1992",
        "ITT Subject 1" => "English",
        "Degree type" => "Bachelor of Arts",
        "Institution" => "Durham University",
        "Degree subject" => "Cardiology",
        "Degree grade" => "First-class Honours",
        "Subject of UG. Degree (Non UK)" => "",
      }
    }

    subject(:trainee) { Trainee.first }

    before do
      described_class.call(csv_row: csv_row)
    end

    describe "#call" do
      it "creates the trainee/degree" do
        expect(Trainee.count).to eq(1)
      end

      context "when Outside UK address is provided" do
        before do
          csv_row.merge!({
            "Postal code" => "100100",
            "Outside UK address" => "Around the world",
          })
          described_class.call(csv_row: csv_row)
        end

        it "sets the locale_code to non-uk" do
          expect(trainee.locale_code).to eq("non_uk")
          expect(trainee.postcode).to be_nil
        end
      end
    end

    describe "setting the post_code" do
      before do
        csv_row.merge!({ "Postal code" => "NE29 9LH" })
      end

      it "returns the post code" do
        described_class.call(csv_row: csv_row)
        expect(trainee.postcode).to eq "NE29 9LH"
      end

      context "with missing whitespace" do
        before do
          csv_row.merge!({ "Postal code" => "NE299LH." })
        end

        it "returns the normalised form" do
          described_class.call(csv_row: csv_row)
          expect(Trainee.last.postcode).to eq "NE29 9LH"
        end
      end
    end

    describe "setting ethnic_group" do
      let(:ethnicity) { "Another ethnic group\n(includes any other ethnic group, for example, Arab)" }

      before do
        csv_row.merge!({ "Ethnicity" => ethnicity })
      end

      it "returns the correct ethnic group" do
        described_class.call(csv_row: csv_row)
        expect(trainee.ethnic_group).to eq Diversities::ETHNIC_GROUP_ENUMS[:other]
      end

      context "with a normalised form" do
        let(:ethnicity) { "anotherethnicgroupincludesanyotherethnicgroupforexamplearab" }

        it "returns the correct ethnic group" do
          described_class.call(csv_row: csv_row)
          expect(trainee.ethnic_group).to eq Diversities::ETHNIC_GROUP_ENUMS[:other]
        end
      end

      context "when the ethnic group cannot be mapped" do
        let(:ethnicity) { "ethnic group" }

        it "raises an error" do
          expect { described_class.call(csv_row: csv_row) }.to raise_error(having_attributes(message: "Ethnic group not recognised: ethnic group"))
        end
      end
    end

    describe "building the degree" do
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
          degree = trainee.degrees.first
          expect(degree.locale_code).to eq "uk"
          expect(degree.trainee).to eq trainee
          expect(degree.uk_degree).to eq "Master of Music"
          expect(degree.grade).to eq "Pass"
          expect(degree.graduation_year).to eq 2021
          expect(degree.institution).to eq "The University of Central Lancashire"
          expect(degree.subject).to eq "Volcanology"
        end
      end

      context "when the degree country row is not blank" do
        let(:csv_row) do
          {
            "Country (Non UK) degree" => "France",
            "UK ENIC equivalent (Non UK)" => "Bachelor degree",
            "Undergrad degree date obtained (Non UK)" => "2021",
            "Degree subject" => "Combined Studies",
            "Subject of UG. Degree (Non UK)" => "Volcanology",
          }
        end

        it "builds a non_uk degree" do
          degree = trainee.degrees.first
          expect(degree.locale_code).to eq "non_uk"
          expect(degree.trainee).to eq trainee
          expect(degree.non_uk_degree).to eq "Bachelor degree"
          expect(degree.graduation_year).to eq 2021
          expect(degree.subject).to eq "Combined Studies"
          expect(degree.country).to eq "France"
        end
      end
    end

    describe "setting the age range" do
      before do
        csv_row.merge!({ "Age range" => age_range })
      end

      context "an age rage can be found" do
        let(:age_range) { "Other 5-14 programme" }

        it "is returned" do
          described_class.call(csv_row: csv_row)
          expect(trainee.course_min_age).to eq(5)
          expect(trainee.course_max_age).to eq(14)
        end
      end

      context "an age rage can't be found" do
        let(:age_range) { "34-97 programme" }

        it "raises an error" do
          expect { described_class.call(csv_row: csv_row) }.to raise_error(having_attributes(message: "Course age range not recognised"))
        end
      end
    end

    describe "setting disabilities" do
      context "when disabilities exist" do
        before do
          csv_row.merge!({ "Disability" => "Learning difficulty\n(for example, dyslexia, dyspraxia or ADHD)" })
          generate_seed_disabilities
        end

        it "sets the correct disability on the trainee" do
          described_class.call(csv_row: csv_row)
          expect(trainee.disabilities.first.name).to eq("Learning difficulty")
        end
      end

      context "when disabilities are not present" do
        it "does not set a disability" do
          expect(trainee.disabilities).to eq([])
        end
      end
    end

    describe "setting schools" do
      before do
        csv_row.merge!({ "Employing school URN" => "123" })
      end

      context "when the school exists" do
        let!(:school) { create(:school, urn: 123) }

        it "sets the employing school on the trainee" do
          described_class.call(csv_row: csv_row)
          expect(trainee.employing_school).to eq(school)
        end
      end

      context "when the school is not present" do
        it "does not set a school" do
          expect(trainee.employing_school).to be_nil
        end
      end
    end

    describe "setting nationalities" do
      context "when nationalities exist" do
        before do
          csv_row.merge!({ "Nationality" => "albanian" })
          generate_seed_nationalities
        end

        it "sets the nationaity" do
          described_class.call(csv_row: csv_row)
          expect(trainee.nationalities.first.name).to eq("albanian")
        end
      end

      context "when nationalities are not present" do
        it "does not set a nationality" do
          expect(trainee.nationaities).to eq([])
        end
      end
    end

    describe "setting the course subject" do
      before do
        csv_row.merge!({ "ITT Subject 1" => itt_subject })
      end

      context "a course subject can be found" do
        let(:itt_subject) { "Design and Technology" }

        it "sets the course_subject_one" do
          described_class.call(csv_row: csv_row)
          expect(trainee.course_subject_one).to eq("Design and technology")
        end
      end

      context "a course subject can't be found" do
        let(:itt_subject) { "Design" }

        it "raises an error" do
          expect { described_class.call(csv_row: csv_row) }.to raise_error(having_attributes(message: "Course subject not recognised: Design"))
        end
      end
    end

    describe "setting the degree grade" do
      before do
        csv_row.merge!({ "Degree grade" => degree_grade })
      end

      context "a degree grade can be found" do
        let(:degree_grade) { "First-class honours" }

        it "sets the degree grade" do
          described_class.call(csv_row: csv_row)
          expect(trainee.degrees.first.grade).to eq("First-class honours")
        end
      end

      context "a degree grade can't be found" do
        let(:degree_grade) { "Summa Cum Laude" }

        it "raises an error" do
          expect { described_class.call(csv_row: csv_row) }.to raise_error(having_attributes(message: "Degree grade not recognised"))
        end
      end
    end

    describe "setting the degree type" do
      before do
        csv_row.merge!({ "Degree type" => degree_type })
      end

      context "the degree type can be found" do
        let(:degree_type) { "Doctor of Divinity" }

        it "sets the degree type" do
          described_class.call(csv_row: csv_row)
          expect(trainee.degrees.map(&:uk_degree)).to include("Doctor of Divinity")
        end
      end

      context "the degree type can't be found" do
        let(:degree_type) { "Master of the universe" }

        it "raises an error" do
          expect { described_class.call(csv_row: csv_row) }.to raise_error "Degree type not recognised: Master of the universe"
        end
      end

      context "with a degree_type abbreviation" do
        let(:degree_type) { "DD" }

        it "returns the degree type" do
          described_class.call(csv_row: csv_row)
          expect(trainee.degrees.map(&:uk_degree)).to include("Doctor of Divinity")
        end
      end

      context "with extra whitespace" do
        let(:degree_type) { " Doctor  of  Divinity  " }

        it "returns the degree type" do
          described_class.call(csv_row: csv_row)
          expect(trainee.degrees.map(&:uk_degree)).to include("Doctor of Divinity")
        end
      end
    end

    describe "setting degree institution" do
      before do
        csv_row.merge!({ "Institution" => degree_institution })
        described_class.call(csv_row: csv_row)
      end

      context "when an exact match is found" do
        let(:degree_institution) { "The University of Manchester" }

        it "returns the degree institution" do
          expect(trainee.degrees.map(&:institution)).to include("The University of Manchester")
        end
      end

      context "when it can't be found" do
        let(:degree_institution) { "University city" }

        it "returns other uk" do
          expect(trainee.degrees.map(&:institution)).to include("Other UK")
        end
      end

      context "with a mapped degree institution" do
        let(:degree_institution) { "Durham University" }

        it "returns the degree institution" do
          expect(trainee.degrees.map(&:institution)).to include("University of Durham")
        end
      end

      context "with extra text in parantheses" do
        let(:degree_institution) { "University of Suffolk (Formerly University Campus Suffolk)" }

        it "returns the degree institution" do
          expect(trainee.degrees.map(&:institution)).to include("University Campus Suffolk")
        end
      end
    end

    describe "setting degree subjects" do
      before do
        csv_row.merge!({ "Degree subject" => degree_subject })
      end

      context "the degree subject can be found" do
        let(:degree_subject) { "Bob Dylan Studies" }

        it "sets the subject" do
          described_class.call(csv_row: csv_row)
          expect(trainee.degrees.map(&:subject)).to include("Bob Dylan Studies")
        end
      end

      context "the degree subject can't be found" do
        let(:degree_subject) { "Astrology" }

        it "raises an error" do
          expect { described_class.call(csv_row: csv_row) }.to raise_error "Degree subject not recognised: Astrology"
        end
      end

      context "with extra whitespace" do
        let(:degree_subject) { " Bob  Dylan  Studies  " }

        it "returns the degree subject" do
          expect(trainee.degrees.map(&:subject)).to include("Bob Dylan Studies")
        end
      end
    end

    describe "ENIC non-uk" do
      before do
        csv_row.merge!({
          "UK ENIC equivalent (Non UK)" => enic,
          "Country (Non UK) degree" => "germany",
        })
      end

      context "the enic value can be found" do
        let(:enic) { "Bachelor degree" }

        it "sets it" do
          described_class.call(csv_row: csv_row)
          expect(trainee.degrees.map(&:non_uk_degree)).to include("Bachelor degree")
        end
      end

      context "the enic value can't be found" do
        let(:enic) {  "Phd" }

        it "raises an error" do
          expect { described_class.call(csv_row: csv_row) }.to raise_error "ENIC equivalent not recognised"
        end
      end

      context "with a blank value" do
        let(:enic) { "" }

        it "returns NON_ENIC" do
          described_class.call(csv_row: csv_row)
          expect(trainee.degrees.map(&:non_uk_degree)).to include(NON_ENIC)
        end
      end
    end
  end
end
