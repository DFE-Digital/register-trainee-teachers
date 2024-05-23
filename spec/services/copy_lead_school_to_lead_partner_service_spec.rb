# frozen_string_literal: true

require "rails_helper"

RSpec.describe CopyLeadSchoolToLeadPartnerService do
  describe "#call" do
    let!(:lead_school_one) { create(:school, :lead) }
    let!(:lead_school_two) { create(:school, :lead) }
    let!(:non_lead_school) { create(:school) }
    let!(:user_one) { create(:user) }
    let!(:user_two) { create(:user) }

    before do
      create(:lead_partner, :lead_school, school: lead_school_one, urn: lead_school_one.urn)
      lead_school_two.users << user_one
    end

    it "creates a lead partner for each lead school that does not have one" do
      expect {
        described_class.call
      }.to change { LeadPartner.count }.by(1)

      expect(LeadPartner.exists?(school_id: lead_school_two.id)).to be true
      expect(LeadPartner.exists?(school_id: non_lead_school.id)).to be false
    end

    it "does not create duplicate lead partners for lead schools" do
      described_class.call
      expect {
        described_class.call
      }.not_to change { LeadPartner.count }

      expect(LeadPartner.where(school_id: lead_school_one.id).count).to eq(1)
    end

    it "creates lead partner users for each user associated with the lead school" do
      expect {
        described_class.call
      }.to change { LeadPartnerUser.count }.by(1)

      lead_partner = LeadPartner.find_by(school_id: lead_school_two.id)
      expect(lead_partner.users).to include(user_one)
    end

    it "does not create duplicate lead partner users" do
      described_class.call
      expect {
        described_class.call
      }.not_to change { LeadPartnerUser.count }

      lead_partner = LeadPartner.find_by(school_id: lead_school_two.id)
      expect(LeadPartnerUser.where(lead_partner_id: lead_partner.id, user_id: user_one.id).count).to eq(1)
    end

    it "updates lead partner users if the users change" do
      described_class.call
      lead_school_two.users << user_two

      expect {
        described_class.call
      }.to change { LeadPartnerUser.count }.by(1)

      lead_partner = LeadPartner.find_by(school_id: lead_school_two.id)
      expect(lead_partner.users).to include(user_one, user_two)
    end

    it "removes lead partner users if the users are removed from the lead school" do
      lead_school_two.users << user_two
      described_class.call
      lead_school_two.users.destroy(user_one)

      expect {
        described_class.call
      }.to change { LeadPartnerUser.count }.by(-1)

      lead_partner = LeadPartner.find_by(school_id: lead_school_two.id)
      expect(lead_partner.users).to include(user_two)
      expect(lead_partner.users).not_to include(user_one)
    end
  end
end
