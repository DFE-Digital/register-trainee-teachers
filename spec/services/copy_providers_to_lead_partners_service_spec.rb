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
      provider_two.users = [user_one]
    end

    context "when record_type is hei" do
      before do
        create(:lead_partner, record_type, provider: provider_one, ukprn: provider_one.ukprn)
      end

      let(:record_type) { :hei }

      it "creates a lead partner for each of the given `provider_ids`" do
        expect {
          described_class.call(provider_ids: [provider_one.id, provider_two.id], record_type: record_type)
        }.to change { LeadPartner.count }.by(1)

        expect(LeadPartner.hei.exists?(provider_id: provider_one.id)).to be true
        expect(LeadPartner.hei.exists?(provider_id: provider_two.id)).to be true
        expect(LeadPartner.hei.exists?(provider_id: provider_three.id)).to be false

        expect(provider_one.reload.accredited).to be false
        expect(provider_two.reload.accredited).to be false
      end
    end

    context "when record_type is scitt" do
      before do
        create(:lead_partner, record_type, provider: provider_one, ukprn: provider_one.ukprn)
      end

      let(:record_type) { :scitt }

      it "creates a lead partner for each of the given `provider_ids`" do
        expect {
          described_class.call(provider_ids: [provider_one.id, provider_two.id], record_type: record_type)
        }.to change { LeadPartner.count }.by(1)

        expect(LeadPartner.scitt.exists?(provider_id: provider_one.id)).to be true
        expect(LeadPartner.scitt.exists?(provider_id: provider_two.id)).to be true
        expect(LeadPartner.scitt.exists?(provider_id: provider_three.id)).to be false

        expect(provider_one.reload.accredited).to be false
        expect(provider_two.reload.accredited).to be false
      end
    end

    context "when record_type is not supported" do
      let(:record_type) { :random }

      it "does not create a lead partner for each of the given `provider_ids`" do
        expect {
          described_class.call(provider_ids: [provider_one.id, provider_two.id], record_type: record_type)
        }.to raise_error(RuntimeError, "'#{record_type}' is not a valid record_type, should be one of [\"hei\", \"scitt\"]")
          .and not_change { LeadPartner.count }

        expect(provider_one.reload.accredited).to be true
        expect(provider_two.reload.accredited).to be true
      end
    end

    it "does not create duplicate lead partners for providers" do
      described_class.call(provider_ids: [provider_one.id], record_type: :hei)
      expect(LeadPartner.where(provider_id: provider_one.id).count).to eq(1)

      expect {
        described_class.call(provider_ids: [provider_one.id], record_type: :hei)
      }.not_to change { LeadPartner.count }

      expect(provider_one.reload.accredited).to be false
    end

    it "creates lead partner users for each user associated with the provider" do
      expect {
        described_class.call(provider_ids: [provider_two.id], record_type: :hei)
      }.to change { LeadPartnerUser.count }.by(1)

      expect(provider_two.reload.accredited).to be false
    end

    it "does not create duplicate lead partner users" do
      described_class.call(provider_ids: [provider_two.id], record_type: :hei)

      lead_partner = LeadPartner.find_by(provider_id: provider_two.id)

      expect(LeadPartnerUser.where(lead_partner_id: lead_partner.id, user_id: user_one.id).count).to eq(1)
      expect {
        described_class.call(provider_ids: [provider_two.id], record_type: :hei)
      }.not_to change { LeadPartnerUser.count }
      expect(provider_two.reload.accredited).to be false
    end

    it "updates lead partner users if the users change" do
      described_class.call(provider_ids: [provider_two.id], record_type: :hei)
      provider_two.users << user_two

      expect {
        described_class.call(provider_ids: [provider_two.id], record_type: :hei)
      }.to change { LeadPartnerUser.count }.by(1)

      lead_partner = LeadPartner.find_by(provider_id: provider_two.id)

      expect(lead_partner.users).to include(user_one, user_two)
      expect(provider_two.reload.accredited).to be false
    end

    it "removes lead partner users if the users are removed from the provider" do
      provider_two.users << user_two
      described_class.call(provider_ids: [provider_two.id], record_type: :hei)
      provider_two.users.destroy(user_one)

      expect {
        described_class.call(provider_ids: [provider_two.id], record_type: :hei)
      }.to change { LeadPartnerUser.count }.by(-1)

      lead_partner = LeadPartner.find_by(provider_id: provider_two.id)

      expect(lead_partner.users).to include(user_two)
      expect(lead_partner.users).not_to include(user_one)
      expect(provider_two.reload.accredited).to be false
    end
  end
end
