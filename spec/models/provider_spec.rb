# frozen_string_literal: true

require "rails_helper"

describe Provider do
  context "fields" do
    it "validates presence" do
      expect(subject).to validate_presence_of(:name).with_message("Enter a provider name")
      expect(subject).to validate_presence_of(:dttp_id).with_message("Enter a DTTP ID in the correct format, like b77c821a-c12a-4133-8036-6ef1db146f9e")
      expect(subject).to validate_presence_of(:ukprn).with_message("Enter a UKPRN in the correct format, like 12345678")
    end

    it "validates format" do
      subject.dttp_id = "XXX"
      subject.code = "abcd 1234"
      subject.ukprn = "3333"
      subject.valid?
      expect(subject.errors[:dttp_id]).to include("Enter a DTTP ID in the correct format, like b77c821a-c12a-4133-8036-6ef1db146f9e")
      expect(subject.errors[:code]).to include("Enter a provider code in the correct format, like 12Y")
      expect(subject.errors[:ukprn]).to include("Enter a UKPRN in the correct format, like 12345678")
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
    it { is_expected.to have_many(:funding_payment_schedules) }
    it { is_expected.to have_many(:funding_trainee_summaries) }
    it { is_expected.to have_many(:recommendations_uploads) }
    it { is_expected.to have_many(:recommended_trainees) }
  end

  describe "auditing" do
    it { is_expected.to be_audited }
    it { is_expected.to have_associated_audits }
  end

  describe "#hpitt_postgrad?" do
    subject { build(:provider, code:).hpitt_postgrad? }

    context "provider is a teach first provider" do
      let(:code) { TEACH_FIRST_PROVIDER_CODE }

      it { is_expected.to be_truthy }
    end

    context "provider is not a teach first provider" do
      let(:code) { TEACH_FIRST_PROVIDER_CODE.reverse }

      it { is_expected.to be_falsey }
    end
  end

  describe "#name_and_code" do
    subject { create(:provider, code: "B1T", name: "DfE University").name_and_code }

    it "returns name and code" do
      expect(subject).to eq("DfE University (B1T)")
    end
  end
end
