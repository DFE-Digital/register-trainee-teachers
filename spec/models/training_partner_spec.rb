# frozen_string_literal: true

require "rails_helper"

describe TrainingPartner do
  context "training partner school" do
    subject(:training_partner) { create(:training_partner, :school) }

    it "creates a school - training partner" do
      expect(training_partner).to be_school
    end
  end

  context "HEI" do
    subject(:training_partner) { create(:training_partner, :hei) }

    it "creates a HEI - training partner" do
      expect(training_partner).to be_hei
    end
  end

  context "SCITT" do
    subject(:training_partner) { create(:training_partner, :scitt) }

    it "creates a SCITT - training partner" do
      expect(training_partner).to be_scitt
    end
  end

  describe "validations" do
    context "for a training partner school" do
      subject(:training_partner) { build(:training_partner, :school) }

      it { is_expected.to validate_presence_of(:urn) }
      it { is_expected.to validate_uniqueness_of(:urn).case_insensitive }
      it { is_expected.to validate_presence_of(:record_type) }

      it { is_expected.to validate_presence_of(:school) }
    end

    context "for an HEI" do
      subject(:training_partner) { build(:training_partner, :hei) }

      it { is_expected.not_to validate_presence_of(:urn) }
      it { is_expected.to validate_presence_of(:record_type) }

      it { is_expected.to validate_presence_of(:ukprn) }
      it { is_expected.to validate_uniqueness_of(:ukprn).case_insensitive }

      it { is_expected.to validate_presence_of(:provider) }
    end
  end

  describe "associations" do
    it { is_expected.to have_many(:training_partner_users) }
    it { is_expected.to have_many(:users).through(:training_partner_users) }
    it { is_expected.to have_many(:trainees) }

    it { is_expected.to belong_to(:school).optional }
    it { is_expected.to belong_to(:provider).optional }
  end

  describe "#funding_payment_schedules" do
    context "when schools exists" do
      subject(:training_partner) { create(:training_partner, :school) }

      it "returns the school#funding_payment_schedules" do
        expect(training_partner.funding_payment_schedules).to eq(
          training_partner.school.funding_payment_schedules,
        )
      end
    end

    context "when provider exists" do
      subject(:training_partner) { create(:training_partner, :hei) }

      it "returns the provider#funding_payment_schedules" do
        expect(training_partner.funding_payment_schedules).to eq(
          training_partner.provider.funding_payment_schedules,
        )
      end
    end

    context "when school and provider are nil" do
      subject(:training_partner) { build(:training_partner) }

      it "returns nil" do
        expect(training_partner.funding_payment_schedules).to be_nil
      end
    end
  end

  describe "#funding_trainee_summaries" do
    context "when schools exists" do
      subject(:training_partner) { create(:training_partner, :school) }

      it "returns the school#funding_trainee_summaries" do
        expect(training_partner.funding_trainee_summaries).to eq(
          training_partner.school.funding_trainee_summaries,
        )
      end
    end

    context "when provider exists" do
      subject(:training_partner) { create(:training_partner, :hei) }

      it "returns the provider#funding_payment_schedules" do
        expect(training_partner.funding_trainee_summaries).to eq(
          training_partner.provider.funding_trainee_summaries,
        )
      end
    end

    context "when school and provider are nil" do
      subject(:training_partner) { build(:training_partner) }

      it "returns nil" do
        expect(training_partner.funding_trainee_summaries).to be_nil
      end
    end
  end

  describe "#name_and_code" do
    context "when schools exists" do
      subject(:training_partner) { create(:training_partner, :hei) }

      it "returns the name of the training partner" do
        expect(training_partner.name_and_code).to eq(training_partner.name)
      end
    end
  end
end
