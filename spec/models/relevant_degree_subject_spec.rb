# frozen_string_literal: true

require "rails_helper"

describe RelevantDegreeSubject do
  subject { create(:relevant_degree_subject) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:hecos_code) }
    it { is_expected.to validate_uniqueness_of(:hecos_code).scoped_to(:academic_cycle_id, :allocation_subject_id).ignoring_case_sensitivity }

    context "when the HECOS code is not a degree subject" do
      subject { build(:relevant_degree_subject, hecos_code: "000000") }

      it "is invalid" do
        subject.validate

        expect(subject.errors[:hecos_code]).to contain_exactly("is not included in the list")
      end
    end

    context "when the HECOS code is the not known degree subject" do
      subject { build(:relevant_degree_subject, hecos_code: "999999") }

      it "is invalid" do
        subject.validate

        expect(subject.errors[:hecos_code]).to contain_exactly("is reserved")
      end
    end

    context "when the HECOS code is the not applicable degree subject" do
      subject { build(:relevant_degree_subject, hecos_code: "999998") }

      it "is invalid" do
        subject.validate

        expect(subject.errors[:hecos_code]).to contain_exactly("is reserved")
      end
    end
  end

  describe "normalizations" do
    it { is_expected.to normalize(:hecos_code).from(" 100417 ").to("100417") }
  end

  describe "associations" do
    it { is_expected.to belong_to(:academic_cycle) }
    it { is_expected.to belong_to(:allocation_subject) }
  end

  describe ".order_by_academic_year_and_subject" do
    let(:current_cycle) { AcademicCycle.current || create(:academic_cycle, :current) }
    let(:next_cycle) { AcademicCycle.next || create(:academic_cycle, next_cycle: true) }
    let(:chemistry) { create(:allocation_subject, name: "Chemistry") }
    let(:physics) { create(:allocation_subject, name: "Physics") }

    let!(:current_physics) { create(:relevant_degree_subject, academic_cycle: current_cycle, allocation_subject: physics, hecos_code: "100425") }
    let!(:next_physics) { create(:relevant_degree_subject, academic_cycle: next_cycle, allocation_subject: physics, hecos_code: "100425") }
    let!(:next_chemistry_physics) { create(:relevant_degree_subject, academic_cycle: next_cycle, allocation_subject: chemistry, hecos_code: "100416") }
    let!(:next_chemistry) { create(:relevant_degree_subject, academic_cycle: next_cycle, allocation_subject: chemistry, hecos_code: "100417") }

    it "orders by newest academic year, then subject name, then HECOS code" do
      expect(described_class.order_by_academic_year_and_subject).to eq(
        [next_chemistry_physics, next_chemistry, next_physics, current_physics],
      )
    end
  end

  describe "#degree_subject_name" do
    subject { build(:relevant_degree_subject, hecos_code: "100416") }

    it "returns the name of the degree subject for the HECOS code" do
      expect(subject.degree_subject_name).to eq("Chemical physics")
    end
  end
end
