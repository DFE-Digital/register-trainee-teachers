# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe MapCourseAgeRangeToHesa do
    describe "::call" do
      subject(:result) { described_class.call(trainee:) }

      context "when the age range has a HESA code" do
        let(:trainee) { build(:trainee, course_min_age: 11, course_max_age: 16) }

        it { is_expected.to eq("13918") }
      end

      context "when the age range is one that maps to a single HESA code" do
        let(:trainee) { build(:trainee, course_min_age: 11, course_max_age: 19) }

        it { is_expected.to eq("13919") }
      end

      context "when the age range has no HESA code" do
        let(:trainee) { build(:trainee, course_min_age: 7, course_max_age: 16) }

        it { is_expected.to be_nil }
      end

      context "when the trainee has no age range" do
        let(:trainee) { build(:trainee, course_min_age: nil, course_max_age: nil) }

        it { is_expected.to be_nil }
      end
    end
  end
end
