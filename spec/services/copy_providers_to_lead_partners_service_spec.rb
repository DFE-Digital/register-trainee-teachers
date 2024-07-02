# frozen_string_literal: true

require "rails_helper"

RSpec.describe CopyProvidersToLeadPartnersService do
  describe "#call" do
    let!(:provider_one) { create(:provider) }
    let!(:provider_two) { create(:provider) }
    let!(:provider_three) { create(:provider) }
    let!(:user_one) { create(:user) }
    let!(:user_two) { create(:user) }

    before do
      create(:lead_partner, :hei, provider: provider_one, ukprn: provider_one.ukprn)
      provider_two.users << user_one
    end

    it "creates a lead partner for each of the given `provider_ids`" do
      expect {
        described_class.call(provider_ids: [provider_one.id, provider_two.id])
      }.to change { LeadPartner.count }.by(1)

      expect(LeadPartner.exists?(provider_id: provider_one.id)).to be true
      expect(LeadPartner.exists?(provider_id: provider_two.id)).to be true
      expect(LeadPartner.exists?(provider_id: provider_three.id)).to be false
    end

    it "does not create duplicate lead partners for providers" do
      described_class.call(provider_ids: [provider_one.id])
      expect(LeadPartner.where(provider_id: provider_one.id).count).to eq(1)

      expect {
        described_class.call(provider_ids: [provider_one.id])
      }.not_to change { LeadPartner.count }
    end

    it "creates lead partner users for each user associated with the provider" do
      expect {
        described_class.call(provider_ids: [provider_two.id])
      }.to change { LeadPartnerUser.count }.by(1)
    end

    it "does not create duplicate lead partner users" do
      described_class.call(provider_ids: [provider_two.id])
      lead_partner = LeadPartner.find_by(provider_id: provider_two.id)
      expect(LeadPartnerUser.where(lead_partner_id: lead_partner.id, user_id: user_one.id).count).to eq(1)

      expect {
        described_class.call(provider_ids: [provider_two.id])
      }.not_to change { LeadPartnerUser.count }
    end

    it "updates lead partner users if the users change" do
      described_class.call(provider_ids: [provider_two.id])
      provider_two.users << user_two

      expect {
        described_class.call(provider_ids: [provider_two.id])
      }.to change { LeadPartnerUser.count }.by(1)

      lead_partner = LeadPartner.find_by(provider_id: provider_two.id)
      expect(lead_partner.users).to include(user_one, user_two)
    end

    it "removes lead partner users if the users are removed from the provider" do
      provider_two.users << user_two
      described_class.call(provider_ids: [provider_two.id])
      provider_two.users.destroy(user_one)

      expect {
        described_class.call(provider_ids: [provider_two.id])
      }.to change { LeadPartnerUser.count }.by(-1)

      lead_partner = LeadPartner.find_by(provider_id: provider_two.id)
      expect(lead_partner.users).to include(user_two)
      expect(lead_partner.users).not_to include(user_one)
    end
  end
end
