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
end
