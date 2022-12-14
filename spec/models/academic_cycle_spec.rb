# frozen_string_literal: true

require "rails_helper"

describe AcademicCycle do
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

  describe "#total_trainees" do
    let(:current_cycle) { create(:academic_cycle, :current) }
    let(:previous_cycle) { create(:academic_cycle, previous_cycle: true) }
    let(:next_cycle) { create(:academic_cycle, next_cycle: true) }

    subject { current_cycle.total_trainees }

    context "a trainee that spans the academic cycle" do
      let(:trainee) { create(:trainee, start_academic_cycle: previous_cycle, end_academic_cycle: next_cycle) }

      it { is_expected.to match_array([trainee]) }
    end

    context "a trainee that ends in the cycle" do
      let(:trainee) { create(:trainee, start_academic_cycle: previous_cycle, end_academic_cycle: current_cycle) }

      it { is_expected.to match_array([trainee]) }
    end
  end

  describe "#trainees_starting" do
    let(:academic_cycle) { build(:academic_cycle) }

    subject { academic_cycle.trainees_starting }

    context "a trainee with trainee_start_date in the cycle" do
      let(:trainee) { create(:trainee, trainee_start_date: academic_cycle.start_date, itt_start_date: nil) }

      it { is_expected.to match_array([trainee]) }
    end

    context "a trainee with itt_start_date in the cycle" do
      let(:trainee) { create(:trainee, itt_start_date: academic_cycle.start_date, trainee_start_date: nil) }

      it { is_expected.to match_array([trainee]) }
    end

    context "a trainee with trainee_start_date in the cycle and itt_start_date outside the cycle" do
      let(:trainee) do
        create(:trainee, itt_start_date: academic_cycle.start_date - 1.day, trainee_start_date: academic_cycle.start_date)
      end

      it "returns the trainee having preferred trainee start date" do
        expect(subject).to match_array([trainee])
      end
    end

    context "a trainee with commencment_date outside the cycle and itt_start_date inside the cycle" do
      let(:trainee) do
        create(:trainee, itt_start_date: academic_cycle.start_date, trainee_start_date: academic_cycle.start_date - 1.day)
      end

      it "does not return the trainee" do
        expect(subject).to be_empty
      end
    end

    context "a trainee that didn't start in the cycle" do
      let(:trainee) { create(:trainee, trainee_start_date: academic_cycle.start_date - 1.day, itt_start_date: nil) }

      it { is_expected.to be_empty }
    end

    context "a trainee with no start dates" do
      let(:trainee) { create(:trainee, :draft, itt_start_date: nil, trainee_start_date: nil) }

      context "the current cycle" do
        let(:academic_cycle) { build(:academic_cycle, :current) }

        it { is_expected.to match_array([trainee]) }
      end

      context "a non-current cycle" do
        let(:academic_cycle) { build(:academic_cycle, previous_cycle: true) }

        it { is_expected.to be_empty }
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

  describe "#current?" do
    around do |example|
      Timecop.freeze(2021, 3, 1) do
        example.run
      end
    end

    subject { academic_year.current? }

    context "Time.now is in the academic year" do
      let(:academic_year) { create(:academic_cycle, cycle_year: 2020) }

      it { is_expected.to be(true) }
    end

    context "Time.now is not in the academic year" do
      let(:academic_year) { create(:academic_cycle, cycle_year: 2021) }

      it { is_expected.to be(false) }
    end
  end

  describe ".current" do
    around do |example|
      Timecop.freeze(2021, 3, 1) do
        example.run
      end
    end

    let(:past_academic_year) { create(:academic_cycle, cycle_year: 2019) }
    let(:current_academic_year) { create(:academic_cycle, cycle_year: 2020) }
    let(:future_academic_year) { create(:academic_cycle, cycle_year: 2021) }

    before do
      past_academic_year
      current_academic_year
      future_academic_year
    end

    subject { described_class.current }

    it { is_expected.to eq(current_academic_year) }
  end
end
