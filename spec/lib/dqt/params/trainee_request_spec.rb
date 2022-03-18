# frozen_string_literal: true

require "rails_helper"

module Dqt
  module Params
    describe TraineeRequest do
      let(:trainee) { create(:trainee, :completed, gender: "female") }
      let(:degree) { trainee.degrees.first }
      let(:degree_subject) { Hesa::CodeSets::DegreeSubjects::MAPPING.invert[degree.subject] }

      describe "#params" do
        subject { described_class.new(trainee: trainee).params }

        it "returns a hash including personal attributes" do
          expect(subject).to include({
            "trn" => trainee.trn,
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
          })
        end

        it "returns a hash including degree attributes" do
          expect(subject["qualification"]).to eq({
            "providerUkprn" => nil,
            "countryCode" => "XK",
            "subject" => degree_subject,
            "class" => described_class::DEGREE_CLASSES[degree.grade],
            "date" => Date.new(degree.graduation_year).iso8601,
          })
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
