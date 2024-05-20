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
end
