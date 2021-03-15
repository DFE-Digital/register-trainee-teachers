# frozen_string_literal: true

require "rails_helper"

module CourseDetails
  describe Update do
    describe ".call" do
      let(:service) { described_class.call(trainee: trainee, attributes: attributes) }

      context "when course details are valid" do
        let(:trainee) { create(:trainee) }

        let(:valid_start_date) do
          Date.parse(5.years.ago.to_s)
        end

        let(:valid_end_date) do
          Date.parse(4.years.ago.to_s)
        end

        let(:attributes) do
          { start_day: valid_start_date.day,
            start_month: valid_start_date.month,
            start_year: valid_start_date.year,
            end_day: valid_end_date.day,
            end_month: valid_end_date.month,
            end_year: valid_end_date.year,
            main_age_range: "other",
            additional_age_range: AgeRange::FOURTEEN_TO_NINETEEN_DIPLOMA,
            subject: "Philosophy" }
        end

        before do
          service.call
          trainee.reload
        end

        it "updates the trainee's course details" do
          expect(trainee.subject).to eq(attributes[:subject])
          expect(trainee.age_range).to eq(attributes[:additional_age_range])
          expect(trainee.course_start_date).to eq(valid_start_date)
          expect(trainee.course_end_date).to eq(valid_end_date)
        end

        it "is successful" do
          expect(service).to be_successful
        end
      end

      context "when course details are invalid" do
        let(:trainee) { create(:trainee, :with_course_details) }

        let(:attributes) do
          { start_day: nil,
            start_month: nil,
            start_year: nil,
            end_day: nil,
            end_month: nil,
            end_year: nil,
            main_age_range: nil,
            additional_age_range: nil,
            subject: nil }
        end

        before do
          service.call
          trainee.reload
        end

        it "does not update the trainee's course details" do
          expect(trainee.subject).to_not eq(nil)
          expect(trainee.age_range).to_not eq(nil)
          expect(trainee.course_start_date).to_not eq(nil)
          expect(trainee.course_end_date).to_not eq(nil)
        end

        it "is unsuccessful" do
          expect(service).to_not be_successful
        end
      end
    end
  end
end
