# frozen_string_literal: true

require "rails_helper"

module Dqt
  module Params
    describe TrnRequest do
      let(:trainee_attributes) { {} }
      let(:degree) { build(:degree, :uk_degree_with_details) }
      let(:hesa_code) { Degrees::DfeReference::SUBJECTS.all.find { _1.name == degree.subject }&.hecos_code }
      let(:hesa_metadatum) { build(:hesa_metadatum) }
      let(:trainee) do
        create(:trainee,
               :completed,
               gender: "female",
               hesa_metadatum: hesa_metadatum,
               degrees: [degree],
               **trainee_attributes)
      end

      describe "#params" do
        subject { described_class.new(trainee: trainee).params }

        let(:uk_address_hash) do
          {

            "addressLine1" => trainee.address_line_one,
            "addressLine2" => trainee.address_line_two,
            "addressLine3" => nil,
            "city" => trainee.town_city,
            "postalCode" => trainee.postcode,
            "country" => described_class::UNITED_KINGDOM,
          }
        end

        it "returns a hash including personal attributes" do
          expect(subject).to include({
            "firstName" => trainee.first_names,
            "middleName" => trainee.middle_names,
            "lastName" => trainee.last_name,
            "birthDate" => trainee.date_of_birth.iso8601,
            "emailAddress" => trainee.email,
            "genderCode" => "Female",
            "address" => uk_address_hash,
          })
        end

        it "returns a hash including course attributes" do
          expect(subject["initialTeacherTraining"]).to eq({
            "providerUkprn" => trainee.provider.ukprn,
            "programmeStartDate" => trainee.itt_start_date.iso8601,
            "programmeEndDate" => trainee.itt_end_date.iso8601,
            "programmeType" => "AssessmentOnlyRoute",
            "subject1" => "100403",
            "subject2" => trainee.course_subject_two,
            "subject3" => trainee.course_subject_three,
            "ageRangeFrom" => trainee.course_min_age,
            "ageRangeTo" => trainee.course_max_age,
            "ittQualificationAim" => described_class::ITT_QUALIFICATION_AIMS[hesa_metadatum.itt_aim],
            "ittQualificationType" => described_class::ITT_QUALIFICATION_TYPES[hesa_metadatum.itt_qualification_aim],
          })
        end

        context "itt_end_date is missing" do
          let(:hesa_metadatum) { build(:hesa_metadatum) }
          let(:trainee_attributes) { { itt_end_date: nil, hesa_metadatum: hesa_metadatum, training_route: training_route, study_mode: study_mode } }

          context "and the trainee is part time" do
            let(:study_mode) { "part_time" }

            context "provider led undergrad" do
              let(:training_route) { "provider_led_undergrad" }

              it "calculates the end date using the course duration data" do
                expect(subject["initialTeacherTraining"]).to include("programmeEndDate" => (trainee.commencement_date + 70.months).iso8601)
              end
            end

            context "and the trainee is school direct tuition fee" do
              let(:training_route) { "school_direct_tuition_fee" }

              it "calculates the end date using the course duration data" do
                expect(subject["initialTeacherTraining"]).to include("programmeEndDate" => (trainee.commencement_date + 22.months).iso8601)
              end
            end
          end

          context "and the trainee is full time" do
            let(:study_mode) { "full_time" }

            context "provider led undergrad" do
              let(:training_route) { "provider_led_undergrad" }

              it "calculates the end date using the course duration data" do
                expect(subject["initialTeacherTraining"]).to include("programmeEndDate" => (trainee.commencement_date + 34.months).iso8601)
              end
            end

            context "and the trainee is school direct tuition fee" do
              let(:training_route) { "school_direct_tuition_fee" }

              it "calculates the end date using the course duration data" do
                expect(subject["initialTeacherTraining"]).to include("programmeEndDate" => (trainee.commencement_date + 10.months).iso8601)
              end
            end
          end

          context "and the training route is opt in undergrad" do
            let(:trainee_attributes) { { itt_end_date: nil, hesa_metadatum: hesa_metadatum, training_route: training_route } }
            let(:training_route) { "opt_in_undergrad" }

            it "calculates the end date using the course duration data" do
              expect(subject["initialTeacherTraining"]).to include("programmeEndDate" => (trainee.commencement_date + 22.months).iso8601)
            end
          end
        end

        it "returns a hash including degree attributes" do
          allow(Degrees::DfeReference::INSTITUTIONS).to receive(:one).with(degree.institution_uuid).and_return(double(ukprn: "12345678"))

          expect(subject["qualification"]).to include({
            "providerUkprn" => "12345678",
            "countryCode" => "XK",
            "subject" => hesa_code,
            "class" => described_class::DEGREE_CLASSES[degree.grade],
            "date" => Date.new(degree.graduation_year).iso8601,
            "heQualificationType" => Dqt::CodeSets::DegreeTypes::MAPPING[degree.uk_degree_uuid],
          })
        end

        context "when there is no degree type" do
          let(:degree) { build(:degree, :uk_degree_with_details, uk_degree_uuid: nil) }

          it "sends nil" do
            expect(subject["qualification"]["heQualificationType"]).to be_nil
          end
        end

        context "when the degree is actually a foundation" do
          let(:degree) { build(:degree, :uk_foundation) }

          it "doesn't send a degree to DQT" do
            expect(subject["qualification"]).to be_nil
          end
        end

        context "when there is no degree graduation year" do
          let(:degree) { build(:degree, graduation_year: nil) }

          it "doesn't send a graduation date" do
            expect(subject["qualification"]["date"]).to be_nil
          end
        end

        context "where there is no institution uuid" do
          let(:degree) { build(:degree, :uk_degree_with_details, institution_uuid: nil) }

          before do
            allow(Degrees::DfeReference::INSTITUTIONS).to receive(:one).with(nil).and_return(nil)
          end

          it "sets the providerUkprn to nil" do
            expect(subject["qualification"]).to match(hash_including("providerUkprn" => nil))
          end
        end

        context "when gender is gender_not_provided" do
          let(:trainee) { create(:trainee, :completed, gender: "prefer_not_to_say") }

          it "maps gender to not provided" do
            expect(subject["genderCode"]).to eq("NotProvided")
          end
        end

        context "when trainee has an international address" do
          let(:trainee) { create(:trainee, :completed, :with_non_uk_address) }

          it "maps international address to addressLine1" do
            expect(subject["address"]).to eq({
              "addressLine1" => trainee.international_address,
            })
          end
        end

        context "when trainee has an international degree" do
          let(:non_uk_degree) { build(:degree, :non_uk_degree_with_details, country: "Albania") }
          let(:trainee) { create(:trainee, :completed, degrees: [non_uk_degree]) }

          it "maps the degree country to HESA countryCode" do
            expect(subject["qualification"]).to include({
              "countryCode" => "AL",
            })
          end

          context "country has extra information" do
            let(:non_uk_degree) { build(:degree, :non_uk_degree_with_details, country: "Hong Kong (Special Administrative Region of China)") }
            let(:trainee) { create(:trainee, :completed, degrees: [non_uk_degree]) }

            it "maps the degree country to HESA countryCode" do
              expect(subject["qualification"]).to include({ "countryCode" => "HK" })
            end
          end
        end

        context "when trainee has no degree" do
          let(:trainee) { create(:trainee, :early_years_undergrad) }

          it "doesn't include qualification" do
            expect(subject["qualification"]).to be_nil
          end
        end

        context "when the trainee course subject one is non-hesa" do
          let(:trainee) { create(:trainee, :completed, course_subject_one: course_subject) }

          context "citizenship" do
            let(:course_subject) { ::CourseSubjects::CITIZENSHIP }

            it "sets subject to 999001" do
              expect(subject["initialTeacherTraining"]["subject1"]).to eq("999001")
            end
          end

          context "physical education" do
            let(:course_subject) { ::CourseSubjects::PHYSICAL_EDUCATION }

            it "sets subject to 999002" do
              expect(subject["initialTeacherTraining"]["subject1"]).to eq("999002")
            end
          end

          context "design and technology" do
            let(:course_subject) { ::CourseSubjects::DESIGN_AND_TECHNOLOGY }

            it "sets subject to 999003" do
              expect(subject["initialTeacherTraining"]["subject1"]).to eq("999003")
            end
          end
        end
      end
    end
  end
end
