# frozen_string_literal: true

require "rails_helper"

module Trs
  module Params
    describe ProfessionalStatus do
      # A completed trainee has all the attributes needed
      let(:trainee) { create(:trainee, :completed, :trn_received) }

      describe "#params" do
        subject { described_class.new(trainee:).params }

        context "when trainee has subjects" do
          let(:trainee) do
            create(:trainee, :completed, :trn_received,
                   course_subject_one: "Primary",
                   course_subject_two: "Mathematics",
                   course_subject_three: nil)
          end

          it "returns the correct subject references" do
            primary_code = Hesa::CodeSets::CourseSubjects::MAPPING.invert["Primary"]
            maths_code = Hesa::CodeSets::CourseSubjects::MAPPING.invert["Mathematics"]

            expect(subject["trainingSubjectReferences"]).to contain_exactly(primary_code, maths_code)
          end
        end

        context "when trainee has no subjects" do
          let(:trainee) { create(:trainee, :completed, :trn_received, course_subject_one: nil, course_subject_two: nil, course_subject_three: nil) }

          it "returns an empty array for subject references" do
            expect(subject["trainingSubjectReferences"]).to eq([])
          end
        end

        it "returns a hash with age range information" do
          expect(subject["trainingAgeSpecialism"]).to eq({
            "type" => "Range",
            "from" => trainee.course_min_age,
            "to" => trainee.course_max_age,
          })
        end

        it "includes a status based on trainee state" do
          expect(subject["status"]).to eq("UnderAssessment")
        end

        context "with degree type information" do
          let(:degree_name) { "Undergraduate Master of Teaching" }
          let(:expected_degree_id) { "dba69141-4101-4e05-80e0-524e3967d589" }
          let(:hesa_metadatum) { build(:hesa_metadatum, itt_qualification_aim: degree_name) }
          let(:trainee) { create(:trainee, :completed, :trn_received, :imported_from_hesa, hesa_metadatum:) }

          it "includes a degree type mapping" do
            expect(subject["degreeTypeId"]).to eq(expected_degree_id)
          end
        end

        context "trainee is deferred" do
          let(:trainee) { create(:trainee, :deferred) }

          it "sets the correcrt status" do
            expect(subject["status"]).to eq("Deferred")
          end
        end

        context "trainee is withdrawn" do
          let(:trainee) { create(:trainee, :withdrawn) }

          it "sets the correcrt status" do
            expect(subject["status"]).to eq("Withdrawn")
          end
        end

        context "trainee is recommended for award" do
          let(:trainee) { create(:trainee, :recommended_for_award) }

          it "sets the correcrt status" do
            expect(subject["status"]).to eq("Approved")
          end
        end

        context "trainee is awarded" do
          let(:trainee) { create(:trainee, :awarded) }

          it "includes awarded date" do
            expect(subject["awardedDate"]).to eq(trainee.awarded_at.to_date.iso8601)
          end
        end

        context "trainee is provider led postgrad" do
          let(:trainee) { create(:trainee, :provider_led_postgrad, :trn_received) }

          it "sets appropriate route type ID" do
            expect(subject["routeTypeId"]).to eq(CodeSets::Trs::ROUTE_TYPES["provider_led_postgrad"])
          end
        end

        context "trainee is school direct tuition fee" do
          let(:trainee) { create(:trainee, :school_direct_tuition_fee, :trn_received) }
          let(:provider_led_trainee) { create(:trainee, :provider_led_postgrad, :trn_received) }

          it "uses a different route type ID than provider led postgrad" do
            provider_led_params = described_class.new(trainee: provider_led_trainee).params

            expect(subject["routeTypeId"]).to eq(CodeSets::Trs::ROUTE_TYPES["school_direct_tuition_fee"])
            expect(subject["routeTypeId"]).not_to eq(provider_led_params["routeTypeId"])
          end
        end

        # Check default country code correctly returned for non-iQTS trainees
        context "when trainee is not iQTS" do
          let(:trainee) { create(:trainee, :provider_led_postgrad, :trn_received) }

          it "defaults to GB as the country reference" do
            expect(subject["trainingCountryReference"]).to eq("GB")
          end
        end

        context "trainee is iQTS" do
          let(:trainee) { create(:trainee, :iqts, :trn_received, iqts_country: "Ireland") }

          it "includes the country reference" do
            expect(subject["trainingCountryReference"]).to eq("IE")
          end
        end

        context "trainee is iQTS in Cyprus" do
          let(:trainee) { create(:trainee, :iqts, :trn_received, iqts_country: "Cyprus") }

          it "maps CY to XC for country code" do
            expect(subject["trainingCountryReference"]).to eq("XC")
          end
        end

        context "trainee is iQTS with a territory country that's in the fallback mapping" do
          let(:trainee) { create(:trainee, :iqts, :trn_received, iqts_country: "Abu Dhabi") }

          it "uses the fallback mapping to get the country code" do
            expect(subject["trainingCountryReference"]).to eq("AE")
          end
        end

        context "when trainee course subject is non-HESA" do
          let(:trainee) do
            create(:trainee, :trn_received, :with_secondary_education).tap do |t|
              t.course_subject_one = course_subject
              t.save
            end
          end

          context "citizenship" do
            let(:course_subject) { ::CourseSubjects::CITIZENSHIP }

            it "sets subject reference to 999001" do
              expect(subject["trainingSubjectReferences"]).to include("999001")
            end
          end

          context "physical education" do
            let(:course_subject) { ::CourseSubjects::PHYSICAL_EDUCATION }

            it "sets subject reference to 999002" do
              expect(subject["trainingSubjectReferences"]).to include("999002")
            end
          end

          context "design and technology" do
            let(:course_subject) { ::CourseSubjects::DESIGN_AND_TECHNOLOGY }

            it "sets subject reference to 999003" do
              expect(subject["trainingSubjectReferences"]).to include("999003")
            end
          end
        end
      end
    end
  end
end
