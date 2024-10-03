# frozen_string_literal: true

require "rails_helper"

module Trainees
  module CreateFromCsvRow
    describe Ambition do
      include SeedHelper
      let!(:academic_cycle) { create(:academic_cycle, :current) }
      let(:employing_school_urn) { "666666" }
      let(:lead_partner_ukprn) { "88888888" }
      let(:first_placement_school_urn) { "166666" }
      let(:second_placement_school_urn) { "266666" }

      let(:csv_row) {
        {
          "Provider Trainee ID" => "ITP-00001",
          "Region" => "North",
          "First Names" => "Bob",
          "Last Name" => "Robertson",
          "Date of Birth" => "03/03/1996 00:00:00",
          "Sex" => "Male",
          "Nationality" => "british",
          "Email"	=> "bob@example.com",
          "Ethnicity"	=> "Not provided",
          "Disabilities" => "Not provided",
          "Course level" => "Postgraduate",
          "Course Education Phase" => "Secondary",
          "Course Age Range" => "11 to 16",
          "Course ITT subject One" => "biology",
          "study mode" => "Full time",
          "Training Route" => "School Direct Tuition Fee",
          "ITT Start Date" => "#{academic_cycle.start_year}-09-09",
          "ITT End Date" => "#{academic_cycle.end_year}-07-31",
          "Trainee Start Date" => "#{academic_cycle.start_year}-09-09",
          "Training Initiative one" => "Not on a Training Initiative",
          "Lead Partner URN or UKPRN" => lead_partner_ukprn,
          "Employing School URN or UKPRN" => employing_school_urn,
          "First Placement URN" => first_placement_school_urn,
          "Second Placement URN" => second_placement_school_urn,
          "Degree Country" => "United Kingdom",
          "Degree Subjects" => "History",
          "Degree UK Degree Types" => "Bachelor of Arts",
          "Degree UK Awarding Institution"	=> "University of Birmingham",
          "Degree UK Grade" => "Upper second-class honours (2:1)",
          "Degree Graduation Year" => "2021",
        }
      }

      let!(:course_allocation_subject) do
        create(:subject_specialism, name: CourseSubjects::BIOLOGY).allocation_subject
      end

      subject(:trainee) { Trainee.first }

      before do
        generate_seed_nationalities
        generate_seed_disabilities
        create(:school, urn: employing_school_urn)
        create(:school, urn: first_placement_school_urn)
        create(:school, urn: second_placement_school_urn)
        create(:lead_partner, :hei, ukprn: lead_partner_ukprn)
        create(:subject_specialism, name: "primary teaching")
      end

      context "with an Ambition CSV" do
        let!(:provider) { create(:provider, :ambition) }

        describe "#call" do
          before do
            described_class.call(csv_row:)
          end

          it "updates the Trainee ID, route, region and record_source" do
            expect(trainee.provider_trainee_id).to eq(csv_row["Provider Trainee ID"])
            expect(trainee.manual_record?).to be(true)
            expect(trainee.training_route).to eq(TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee])
            expect(trainee.region).to eq(csv_row["Region"])
          end

          it "updates the trainee's personal details" do
            expect(trainee.first_names).to eq(csv_row["First Names"])
            expect(trainee.last_name).to eq(csv_row["Last Name"])
            expect(trainee.sex).to eq("male")
            expect(trainee.date_of_birth).to eq(Date.parse(csv_row["Date of Birth"]))
            expect(trainee.nationalities.pluck(:name)).to include("british")
            expect(trainee.email).to eq(csv_row["Email"])
          end

          it "updates trainee's course details" do
            expect(trainee.course_allocation_subject).to eq(course_allocation_subject)
            expect(trainee.course_education_phase).to eq(COURSE_EDUCATION_PHASE_ENUMS[:secondary])
            expect(trainee.course_subject_one).to eq(::CourseSubjects::BIOLOGY)
            expect(trainee.course_subject_two).to be_nil
            expect(trainee.course_subject_three).to be_nil
            expect(trainee.course_age_range).to eq(DfE::ReferenceData::AgeRanges::ELEVEN_TO_SIXTEEN)
            expect(trainee.study_mode).to eq("full_time")
            expect(trainee.itt_start_date).to eq(Date.parse(csv_row["ITT Start Date"]))
            expect(trainee.itt_end_date).to eq(Date.parse(csv_row["ITT End Date"]))
            expect(trainee.start_academic_cycle).to eq(academic_cycle)
            expect(trainee.end_academic_cycle).to eq(academic_cycle)
            expect(trainee.trainee_start_date).to eq(Date.parse(csv_row["Trainee Start Date"]))
          end

          it "updates the trainee's school and training details" do
            expect(trainee.lead_partner.ukprn).to eq(lead_partner_ukprn)
            expect(trainee.employing_school.urn).to eq(employing_school_urn)
            expect(trainee.training_initiative).to eq(ROUTE_INITIATIVES_ENUMS[:no_initiative])
          end

          it "creates the trainee's degree" do
            degree = trainee.degrees.last
            expect(degree.locale_code).to eq("uk")
            expect(degree.uk_degree).to eq("Bachelor of Arts")
            expect(degree.non_uk_degree).to be_nil
            expect(degree.subject).to eq("History")
            expect(degree.institution).to eq("University of Birmingham")
            expect(degree.graduation_year).to eq(2021)
            expect(degree.grade).to eq("Upper second-class honours (2:1)")
            expect(degree.other_grade).to be_nil
            expect(degree.country).to be_nil
          end

          it "creates the trainee's placements" do
            expect(trainee.reload.placements.first.school.urn).to eq(first_placement_school_urn)
            expect(trainee.placements.second.school.urn).to eq(second_placement_school_urn)
          end
        end

        context "when the degree institution UKPRN is provided" do
          before do
            csv_row.merge!({ "Degree UK Awarding Institution" => "10007163" })
            described_class.call(csv_row:)
          end

          it "creates the trainee's degree with the correct institution" do
            expect(trainee.degrees.first.institution).to eq("University of Warwick")
          end
        end

        context "when the degree is not from the UK" do
          before do
            csv_row.merge!({
              "Degree Country" => "Germany",
              "Degree Subjects" => "Akkadian language",
              "Degree UK Degree Types" => "",
              "Degree UK Awarding Institution"	=> "",
              "Degree UK Grade" => "",
              "Degree Non-UK Degree Types" => "Bachelor degree",
              "Degree Graduation Year" => "2021",
            })
            described_class.call(csv_row:)
          end

          it "create's the trainee's non-uk degree" do
            degree = trainee.degrees.last
            expect(degree.locale_code).to eq("non_uk")
            expect(degree.uk_degree).to be_nil
            expect(degree.non_uk_degree).to eq("Bachelor degree")
            expect(degree.subject).to eq("Akkadian language")
            expect(degree.institution).to be_nil
            expect(degree.graduation_year).to eq(2021)
            expect(degree.grade).to be_nil
            expect(degree.other_grade).to be_nil
            expect(degree.country).to eq("Germany")
          end
        end

        describe "setting the trainee's diversity details" do
          context "when ethnicity is 'Not provided'" do
            it "sets the ethnic_group and background to 'Not provided'" do
              described_class.call(csv_row:)
              expect(trainee.ethnic_group).to eq(Diversities::ETHNIC_GROUP_ENUMS[:not_provided])
              expect(trainee.ethnic_background).to eq(Diversities::NOT_PROVIDED)
              expect(trainee.diversity_disclosure).to eq(Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_not_disclosed])
            end
          end

          context "when ethnicity is provided" do
            before do
              csv_row.merge!({ "Ethnicity" => "Black - Caribbean or Caribbean British" })
              described_class.call(csv_row:)
            end

            it "sets the ethnic_group and background" do
              expect(trainee.ethnic_group).to eq(Diversities::ETHNIC_GROUP_ENUMS[:black])
              expect(trainee.ethnic_background).to eq(Diversities::CARIBBEAN)
            end
          end

          context "when ethnicity is provided with additional ethnic background" do
            before do
              csv_row.merge!({ "Ethnicity" => "Any other Black background: Afghan" })
              described_class.call(csv_row:)
            end

            it "sets the ethnic_group, background and additional background" do
              expect(trainee.ethnic_group).to eq(Diversities::ETHNIC_GROUP_ENUMS[:black])
              expect(trainee.ethnic_background).to eq(Diversities::ANOTHER_BLACK_BACKGROUND)
              expect(trainee.additional_ethnic_background).to eq("Afghan")
            end
          end

          context "when disability is provided" do
            before do
              csv_row.merge!({ "Disabilities" => "Learning difficulty" })
              described_class.call(csv_row:)
            end

            it "sets the disability and disability disclosure" do
              expect(trainee.disabilities.first.name).to eq("Learning difficulty")
              expect(trainee.diversity_disclosure).to eq(Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed])
              expect(trainee.disability_disclosure).to eq(Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled])
            end
          end

          context "when disability is provided as \"Other:\"" do
            before do
              csv_row.merge!({ "Disabilities" => "Other: something else" })
              described_class.call(csv_row:)
            end

            it "sets disability to other and records 'something else' to additional_disability" do
              expect(trainee.disabilities.first.name).to eq("Other")
              expect(trainee.diversity_disclosure).to eq(Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed])
              expect(trainee.trainee_disabilities.first.additional_disability).to eq("something else")
            end
          end

          context "when disability is provided as No known disability" do
            before do
              csv_row.merge!({ "Disabilities" => "No disabilities" })
              described_class.call(csv_row:)
            end

            it "sets no disabilities on the trainee and sets the disability disclosures correctly" do
              expect(trainee.diversity_disclosure).to eq(Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed])
              expect(trainee.disability_disclosure).to eq(Diversities::DISABILITY_DISCLOSURE_ENUMS[:no_disability])
              expect(trainee.disabilities).to be_empty
            end
          end

          context "when multiple disabilities are provided" do
            before do
              csv_row.merge!({ "Disabilities" => "Learning difficulty, Long-standing illness" })
              described_class.call(csv_row:)
            end

            it "sets the disabilities and disability disclosure" do
              expect(trainee.disabilities.map(&:name)).to include("Learning difficulty", "Long-standing illness")
              expect(trainee.diversity_disclosure).to eq(Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed])
              expect(trainee.disability_disclosure).to eq(Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled])
            end
          end
        end

        context "when the trainee's course is in the primary age range but subject isn't" do
          before do
            csv_row.merge!({ "Course Age Range" => "7 to 11" })
            described_class.call(csv_row:)
          end

          it "adds 'primary teaching' and places it in the course_subject_one column" do
            expect(trainee.course_subject_one).to eq(CourseSubjects::PRIMARY_TEACHING)
            expect(trainee.course_subject_two).to eq(CourseSubjects::BIOLOGY)
          end
        end

        context "when the trainee's course is in the primary age range but primary subject not the first subject" do
          before do
            csv_row.merge!({
              "Course Age Range" => "7 to 11",
              "Course ITT subject Two" => "primary teaching",
            })
            described_class.call(csv_row:)
          end

          it "moves 'primary teaching' to be the first subject" do
            expect(trainee.course_subject_one).to eq(CourseSubjects::PRIMARY_TEACHING)
            expect(trainee.course_subject_two).to eq(CourseSubjects::BIOLOGY)
          end
        end

        context "when nationality is provided as 'other'" do
          before do
            csv_row.merge!({ "Nationality" => "other" })
            described_class.call(csv_row:)
          end

          it "doesn't error and leaves the nationality blank" do
            expect(trainee.nationalities).to be_empty
          end
        end

        context "when nationality is provided as 'english'" do
          before do
            csv_row.merge!({ "Nationality" => "english" })
            described_class.call(csv_row:)
          end

          it "doesn't error and sets nationality to british" do
            expect(trainee.nationalities.pluck(:name)).to include("british")
          end
        end
      end
    end
  end
end
