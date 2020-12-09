# frozen_string_literal: true

require "rails_helper"

module ProgrammeDetails
  describe Update do
    describe ".call" do
      let(:service) { described_class.call(trainee: trainee, attributes: attributes) }

      context "when programme details are valid" do
        let(:trainee) { create(:trainee) }

        let(:date) do
          Date.new(1999, 12, 31)
        end
        let(:attributes) do
          { start_day: date.day.to_s,
            start_month: date.month.to_s,
            start_year: date.year.to_s,
            end_day: date.day.to_s,
            end_month: date.month.to_s,
            end_year: date.year.to_s,
            main_age_range: "other",
            additional_age_range: "14 - 19 diploma",
            subject: "Philosophy" }
        end

        before do
          service.call
          trainee.reload
        end

        it "updates the trainee's programme details" do
          expect(trainee.subject).to eq(attributes[:subject])
          expect(trainee.age_range).to eq(attributes[:additional_age_range])
          expect(trainee.programme_start_date).to eq(date)
          expect(trainee.programme_end_date).to eq(date)
        end

        it "is successful" do
          expect(service).to be_successful
        end
      end

      context "when programme details are invalid" do
        let(:trainee) { create(:trainee, :with_programme_details) }

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

        it "does not update the trainee's programme details" do
          expect(trainee.subject).to_not eq(nil)
          expect(trainee.age_range).to_not eq(nil)
          expect(trainee.programme_start_date).to_not eq(nil)
        end

        it "is unsuccessful" do
          expect(service).to_not be_successful
        end
      end
    end
  end
end
