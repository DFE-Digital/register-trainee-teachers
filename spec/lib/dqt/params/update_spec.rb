# frozen_string_literal: true

require "rails_helper"

module Dqt
  module Params
    describe Update do
      let(:trainee) { create(:trainee, :completed, sex: "female", hesa_id: 1) }
      let(:degree) { trainee.degrees.first }
      let(:hesa_code) { DfEReference::DegreesQuery::SUBJECTS.all.find { it.name == degree.subject }&.hecos_code }
      let(:ukprn) { DfEReference::DegreesQuery::INSTITUTIONS.one(degree.institution_uuid)[:ukprn] }
      let(:dqt_degree_type) { "BachelorOfArts" }
      let(:uk_degree_uuid) { "db695652-c197-e711-80d8-005056ac45bb" }

      before do
        degree.uk_degree_uuid = uk_degree_uuid
      end

      describe "#params" do
        subject { described_class.new(trainee:).params }

        it "returns a hash including personal attributes" do
          expect(subject).to include({
            "trn" => trainee.trn,
            "husid" => trainee.hesa_id,
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
            "ittQualificationAim" => nil,
            "ittQualificationType" => nil,
            "trainingCountryCode" => nil,
          })
        end

        it "returns a hash including degree attributes" do
          expect(subject["qualification"]).to eq({
            "providerUkprn" => ukprn,
            "countryCode" => "XK",
            "subject" => hesa_code,
            "class" => described_class::DEGREE_CLASSES[degree.grade],
            "date" => Date.new(degree.graduation_year).iso8601,
            "heQualificationType" => dqt_degree_type,
          })
        end

        context "trainee is deferred" do
          let(:trainee) { create(:trainee, :completed, :deferred) }

          it "sets the outcome param to Deferred" do
            expect(subject["initialTeacherTraining"]).to include({ "outcome" => "Deferred" })
          end
        end

        context "trainee is in training" do
          let(:trainee) { create(:trainee, :completed, :school_direct_tuition_fee, :submitted_for_trn) }

          it "sets the outcome param to Deferred" do
            expect(subject["initialTeacherTraining"]).to include({ "outcome" => "InTraining" })
          end

          context "assessment only route" do
            let(:trainee) { create(:trainee, :completed, :assessment_only, :trn_received) }

            it "sets the outcome param to Deferred" do
              expect(subject["initialTeacherTraining"]).to include({ "outcome" => "UnderAssessment" })
            end
          end
        end

        context "is allowed to update PII" do
          let(:trainee) do
            create(:trainee, :completed, :assessment_only, sex: :male, dqt_teacher: create(:dqt_teacher, allowed_pii_updates: true))
          end

          it "returns a hash including personal attributes" do
            expect(subject).to include({
              "firstName" => trainee.first_names,
              "middleName" => trainee.middle_names,
              "lastName" => trainee.last_name,
              "emailAddress" => trainee.email,
              "genderCode" => "Male",
              "dateOfBirth" => trainee.date_of_birth.iso8601,
            })
          end
        end

        context "trainee is not deferred or in training" do
          let(:trainee) { create(:trainee, :completed, :withdrawn) }

          it "doesn't add the outcome params" do
            expect(subject["initialTeacherTraining"]).not_to have_key("outcome")
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
        end
      end
    end
  end
end
