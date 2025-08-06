# frozen_string_literal: true

require "rails_helper"

module TeacherTrainingApi
  describe CheckCoursesForMissingProviders do
    describe "#call" do
      let(:provider)  { create(:provider, code: "A001") }
      let(:course1)   { create(:course, recruitment_cycle_year:, provider:) }
      let(:course2)   { create(:course, recruitment_cycle_year: recruitment_cycle_year, accredited_body_code: "A002") }
      let(:course3)   { create(:course, recruitment_cycle_year: recruitment_cycle_year, accredited_body_code: "A003") }
      let(:recruitment_cycle_year) { Settings.current_recruitment_cycle_year }

      subject { described_class.call }

      around do |example|
        Timecop.freeze(Time.zone.now) { example.run }
      end

      context "when there is one course with a missing provider" do
        it "reports the number of missing courses" do
          provider
          course1
          course2

          expect(subject[:recruitment_cycle_year]).to eq(recruitment_cycle_year)
          expect(subject[:courses_with_missing_provider_count]).to eq(1)
          expect(subject[:message]).to eq("[#{Rails.env}] [#{Time.zone.now.to_fs(:govuk_date_and_time)}] CheckCoursesForMissingProviders - There is 1 course with a missing provider for recruitment cycle year #{recruitment_cycle_year}. The missing provider code is A002.")
        end
      end

      context "when there are multiple courses with a missing provider" do
        it "reports the number of missing courses" do
          provider
          course1
          course2
          course3

          expect(subject[:recruitment_cycle_year]).to eq(recruitment_cycle_year)
          expect(subject[:courses_with_missing_provider_count]).to eq(2)
          expect(subject[:message]).to eq("[#{Rails.env}] [#{Time.zone.now.to_fs(:govuk_date_and_time)}] CheckCoursesForMissingProviders - There are 2 courses with missing providers for recruitment cycle year #{recruitment_cycle_year}. The missing provider codes are A002, A003.")
        end
      end

      context "when there are no courses with missing providers" do
        it "reports there are no missing courses" do
          provider
          course1

          expect(subject[:recruitment_cycle_year]).to eq(recruitment_cycle_year)
          expect(subject[:courses_with_missing_provider_count]).to eq(0)
          expect(subject[:message]).to eq("[#{Rails.env}] [#{Time.zone.now.to_fs(:govuk_date_and_time)}] CheckCoursesForMissingProviders - There are no courses with missing providers for recruitment cycle year #{recruitment_cycle_year}.")
        end
      end
    end
  end
end
