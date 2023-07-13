# frozen_string_literal: true

require "rails_helper"

describe CourseYearsForm, type: :model do
  let(:params) { {} }

  subject { described_class.new(params:) }

  describe "validations" do
    it { is_expected.to validate_inclusion_of(:course_year).in_array(subject.course_years_options.keys) }
  end

  describe "#course_year" do
    before do
      create(:academic_cycle, :current)
      create(:academic_cycle, previous_cycle: true)
      create(:academic_cycle, next_cycle: true)
    end

    context "with a `course_year` param" do
      let(:params) { { course_year: 2025 } }

      it "params override default" do
        expect(subject.course_year).to eq(2025)
      end
    end

    context "3 months before end of cycle" do
      around do |example|
        Timecop.freeze(Date.new(2023, 5, 1)) { example.run }
      end

      it "defaults to the current cycle" do
        expect(subject.course_year).to eq(2022)
      end
    end

    context "3 weeks before end of cycle" do
      around do |example|
        Timecop.freeze(Date.new(2023, 7, 10)) { example.run }
      end

      it "defaults to the next cycle" do
        expect(subject.course_year).to eq(2023)
      end
    end
  end

  describe "#course_years_options" do
    before do
      allow(Settings).to receive(:current_default_course_year).and_return(2010)
    end

    it "returns course years hash" do
      expect(subject.course_years_options).to eql({
        2010 => "2010 to 2011",
        2009 => "2009 to 2010",
      })
    end
  end
end
