# frozen_string_literal: true

require "rails_helper"

describe AcademicCycle, type: :model do
  subject { build(:academic_cycle) }

  it { is_expected.to be_valid }

  describe "validations" do
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:end_date) }

    context "dates" do
      context "when invalid values are given" do
        subject { build(:academic_cycle, start_date: "assasd") }

        it { is_expected.not_to be_valid }
      end

      context "when start date is after end date" do
        subject { build(:academic_cycle, start_date: Time.zone.today, end_date: Time.zone.yesterday) }

        it { is_expected.not_to be_valid }
      end
    end
  end

  describe "#trainees" do
    context "when there are trainees across different year periods" do
      let(:trainee) { create(:trainee, commencement_date: subject.start_date) }
      let(:trainee2) { create(:trainee, course_start_date: subject.start_date + 1.day) }

      before do
        incorrect_day = subject.start_date - 1.day
        create(:trainee, commencement_date: incorrect_day, course_start_date: incorrect_day)
      end

      it "returns the trainees based on the start and end date of the cycle" do
        expect(subject.trainees_starting).to match_array([trainee, trainee2])
      end
    end
  end

  describe "#for_year" do
    let!(:academic_cycle1) { create(:academic_cycle, start_date: "01/9/2019", end_date: "31/8/2020") }
    let!(:academic_cycle2) { create(:academic_cycle, start_date: "01/9/2020", end_date: "31/8/2021") }
    let!(:academic_cycle3) { create(:academic_cycle, start_date: "01/9/2021", end_date: "31/8/2022") }

    it "returns correct academic_cycle" do
      expect(AcademicCycle.for_year(2019)).to eql(academic_cycle1)
      expect(AcademicCycle.for_year(2020)).to eql(academic_cycle2)
      expect(AcademicCycle.for_year(2021)).to eql(academic_cycle3)
    end
  end

  describe "#start_year" do
    it "returns start year" do
      expect(build(:academic_cycle, start_date: "01/9/2019", end_date: "31/8/2020").start_year).to be(2019)
      expect(build(:academic_cycle, start_date: "01/9/2020", end_date: "31/8/2021").start_year).to be(2020)
      expect(build(:academic_cycle, start_date: "01/9/2021", end_date: "31/8/2022").start_year).to be(2021)
    end
  end
end
