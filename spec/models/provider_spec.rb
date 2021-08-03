# frozen_string_literal: true

require "rails_helper"

describe Provider do
  context "fields" do
    it "validates presence" do
      expect(subject).to validate_presence_of(:name).with_message("Enter a provider name")
      expect(subject).to validate_presence_of(:dttp_id).with_message("Enter a DTTP ID in the correct format, like b77c821a-c12a-4133-8036-6ef1db146f9e")
    end

    it "validates format" do
      subject.dttp_id = "XXX"
      subject.code = "abcd 1234"
      subject.valid?
      expect(subject.errors[:dttp_id]).to include("Enter a DTTP ID in the correct format, like b77c821a-c12a-4133-8036-6ef1db146f9e")
      expect(subject.errors[:code]).to include("Enter a provider code in the correct format, like 12Y")
    end
  end

  context "validates dttp_id" do
    subject { create(:provider) }

    it "validates uniqueness" do
      expect(subject).to validate_uniqueness_of(:dttp_id).case_insensitive.with_message("Enter a unique DTTP ID")
    end
  end

  describe "indexes" do
    it { is_expected.to have_db_index(:dttp_id).unique(true) }
  end

  describe "associations" do
    it { is_expected.to have_many(:users) }
    it { is_expected.to have_many(:apply_applications) }
  end

  describe "auditing" do
    it { is_expected.to be_audited }
    it { is_expected.to have_associated_audits }
  end

  describe "#hpitt_postgrad?" do
    let(:hpitt_provider) { create(:provider) }

    context "provider is a teach first provider" do
      subject { build(:provider, code: hpitt_provider.code) }

      it "returns true" do
        expect(subject.hpitt_postgrad?).to be true
      end
    end

    context "provider is not a teach first provider" do
      subject { build(:provider, code: hpitt_provider.code.reverse) }

      it "returns false" do
        expect(subject.hpitt_postgrad?).to be false
      end
    end
  end
end
