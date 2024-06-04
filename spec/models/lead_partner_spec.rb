# frozen_string_literal: true

require "rails_helper"

describe LeadPartner do
  context "lead school" do
    subject(:lead_partner) { create(:lead_partner, :lead_school) }

    it "creates a lead school - lead partner" do
      expect(lead_partner).to be_lead_school
    end
  end

  context "HEI" do
    subject(:lead_partner) { create(:lead_partner, :hei) }

    it "creates a HEI - lead partner" do
      expect(lead_partner).to be_hei
    end
  end

  describe "validations" do
    context "for a lead school" do
      subject(:lead_partner) { build(:lead_partner, :lead_school) }

      it { is_expected.to validate_presence_of(:urn) }
      it { is_expected.to validate_uniqueness_of(:urn).case_insensitive }
      it { is_expected.to validate_presence_of(:record_type) }

      it { is_expected.to validate_presence_of(:school) }
    end

    context "for an HEI" do
      subject(:lead_partner) { build(:lead_partner, :hei) }

      it { is_expected.to validate_presence_of(:urn) }
      it { is_expected.to validate_uniqueness_of(:urn).case_insensitive }
      it { is_expected.to validate_presence_of(:record_type) }

      it { is_expected.to validate_presence_of(:ukprn) }
      it { is_expected.to validate_uniqueness_of(:ukprn).case_insensitive }

      it { is_expected.to validate_presence_of(:provider) }
    end
  end
end
