# frozen_string_literal: true

require "rails_helper"

describe LeadPartner do
  context "lead school" do
    subject(:lead_partner) { create(:lead_partner, :school) }

    it "creates a lead school - lead partner" do
      expect(lead_partner).to be_school
    end
  end

  context "HEI" do
    subject(:lead_partner) { create(:lead_partner, :hei) }

    it "creates a HEI - lead partner" do
      expect(lead_partner).to be_hei
    end
  end

  context "SCITT" do
    subject(:lead_partner) { create(:lead_partner, :scitt) }

    it "creates a SCITT - lead partner" do
      expect(lead_partner).to be_scitt
    end
  end

  describe "validations" do
    context "for a lead school" do
      subject(:lead_partner) { build(:lead_partner, :school) }

      it { is_expected.to validate_presence_of(:urn) }
      it { is_expected.to validate_uniqueness_of(:urn).case_insensitive }
      it { is_expected.to validate_presence_of(:record_type) }

      it { is_expected.to validate_presence_of(:school) }
    end

    context "for an HEI" do
      subject(:lead_partner) { build(:lead_partner, :hei) }

      it { is_expected.not_to validate_presence_of(:urn) }
      it { is_expected.to validate_presence_of(:record_type) }

      it { is_expected.to validate_presence_of(:ukprn) }
      it { is_expected.to validate_uniqueness_of(:ukprn).case_insensitive }

      it { is_expected.to validate_presence_of(:provider) }
    end
  end

  describe "associations" do
    it { is_expected.to have_many(:lead_partner_users) }
    it { is_expected.to have_many(:users).through(:lead_partner_users) }
    it { is_expected.to have_many(:trainees) }

    it { is_expected.to belong_to(:school).optional }
    it { is_expected.to belong_to(:provider).optional }
  end

  describe "#funding_payment_schedules" do
    context "when schools exists" do
      subject(:lead_partner) { create(:lead_partner, :school) }

      it "returns the school#funding_payment_schedules" do
        expect(lead_partner.funding_payment_schedules).to eq(
          lead_partner.school.funding_payment_schedules,
        )
      end
    end

    context "when provider exists" do
      subject(:lead_partner) { create(:lead_partner, :hei) }

      it "returns the provider#funding_payment_schedules" do
        expect(lead_partner.funding_payment_schedules).to eq(
          lead_partner.provider.funding_payment_schedules,
        )
      end
    end

    context "when school and provider are nil" do
      subject(:lead_partner) { build(:lead_partner) }

      it "returns nil" do
        expect(lead_partner.funding_payment_schedules).to be_nil
      end
    end
  end

  describe "#funding_trainee_summaries" do
    context "when schools exists" do
      subject(:lead_partner) { create(:lead_partner, :school) }

      it "returns the school#funding_trainee_summaries" do
        expect(lead_partner.funding_trainee_summaries).to eq(
          lead_partner.school.funding_trainee_summaries,
        )
      end
    end

    context "when provider exists" do
      subject(:lead_partner) { create(:lead_partner, :hei) }

      it "returns the provider#funding_payment_schedules" do
        expect(lead_partner.funding_trainee_summaries).to eq(
          lead_partner.provider.funding_trainee_summaries,
        )
      end
    end

    context "when school and provider are nil" do
      subject(:lead_partner) { build(:lead_partner) }

      it "returns nil" do
        expect(lead_partner.funding_trainee_summaries).to be_nil
      end
    end
  end

  describe "#name_and_code" do
    context "when schools exists" do
      subject(:lead_partner) { create(:lead_partner, :hei) }

      it "returns the name of the lead partner" do
        expect(lead_partner.name_and_code).to eq(lead_partner.name)
      end
    end
  end
end
