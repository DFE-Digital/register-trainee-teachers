# frozen_string_literal: true

require "rails_helper"

describe DiversityForm, type: :model do
  let(:trainee) { build(:trainee) }

  subject { described_class.new(trainee) }

  describe "#diversity_disclosure" do
    before do
      allow(Diversities::EthnicBackgroundForm).to receive(:new) # form also calls diversity_disclosure() on initialisation
      allow(Diversities::DisabilityDisclosureForm).to receive(:new) # form also calls diversity_disclosure() on initialisation
      allow(Diversities::DisabilityDetailForm).to receive(:new) # form also calls diversity_disclosure() on initialisation
      allow(Diversities::EthnicGroupForm).to receive(:new) # form also calls diversity_disclosure() on initialisation
    end

    it "delegates to Diversities::DisclosureForm#diversity_disclosure" do
      expect_any_instance_of(Diversities::DisclosureForm).to receive(:diversity_disclosure)

      subject.diversity_disclosure
    end
  end

  describe "#disabled?" do
    before do
      allow(Diversities::DisabilityDetailForm).to receive(:new) # form also calls disabled?() on initialisation
    end

    it "delegates to Diversities::DisabilityDisclosureForm#disabled?" do
      expect_any_instance_of(Diversities::DisabilityDisclosureForm).to receive(:disabled?)

      subject.disabled?
    end
  end

  describe "#no_disability??" do
    it "delegates to Diversities::DisabilityDisclosureForm#no_disability?" do
      expect_any_instance_of(Diversities::DisabilityDisclosureForm).to receive(:no_disability?)

      subject.no_disability?
    end
  end

  describe "#disabilities" do
    it "delegates to Diversities::DisabilityDetailForm#disabilities" do
      expect_any_instance_of(Diversities::DisabilityDetailForm).to receive(:disabilities)

      subject.disabilities
    end
  end

  describe "#ethnic_group" do
    it "delegates to Diversities::EthnicGroupForm#ethnic_group" do
      expect_any_instance_of(Diversities::EthnicGroupForm).to receive(:ethnic_group)

      subject.ethnic_group
    end
  end

  describe "#ethnic_background" do
    it "delegates to Diversities::EthnicBackgroundForm#ethnic_background" do
      expect_any_instance_of(Diversities::EthnicBackgroundForm).to receive(:ethnic_background)

      subject.ethnic_background
    end
  end

  describe "#additional_ethnic_background" do
    it "delegates to Diversities::EthnicBackgroundForm#additional_ethnic_background" do
      expect_any_instance_of(Diversities::EthnicBackgroundForm).to receive(:additional_ethnic_background)

      subject.additional_ethnic_background
    end
  end

  describe "#save!" do
    it "calls the save! method on all diversity forms" do
      expect_any_instance_of(Diversities::DisabilityDetailForm).to receive(:save!)
      expect_any_instance_of(Diversities::DisabilityDisclosureForm).to receive(:save!)
      expect_any_instance_of(Diversities::DisclosureForm).to receive(:save!)
      expect_any_instance_of(Diversities::EthnicBackgroundForm).to receive(:save!)
      expect_any_instance_of(Diversities::EthnicGroupForm).to receive(:save!)

      subject.save!
    end
  end

  describe "#missing_fields" do
    subject { described_class.new(trainee).missing_fields }

    it { is_expected.to eq([]) }

    context "with invalid diversity forms" do
      let(:trainee) { build(:trainee, diversity_disclosure: nil) }

      it { is_expected.to eq([:diversity_disclosure]) }
    end

    context "with multiple invalid diversity forms" do
      let(:trainee) { build(:trainee, :diversity_disclosed, :disabled) }

      it { is_expected.to eq(%i[ethnic_background ethnic_group disability_ids]) }
    end
  end
end
