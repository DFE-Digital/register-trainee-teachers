# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CopyLeadSchoolToLeadPartnerService do
  describe '#call' do
    let!(:lead_school_1) { create(:school, :lead) }
    let!(:lead_school_2) { create(:school, :lead) }
    let!(:non_lead_school) { create(:school) }

    before do
      create(:lead_partner, :lead_school, school: lead_school_1, urn: lead_school_1.urn)
    end

    it 'creates a lead partner for each lead school that does not have one' do
      expect {
        described_class.new.call
      }.to change { LeadPartner.count }.by(1)

      expect(LeadPartner.exists?(school_id: lead_school_2.id)).to be true
      expect(LeadPartner.exists?(school_id: non_lead_school.id)).to be false
    end

    it 'does not create duplicate lead partners for lead schools' do
      described_class.new.call
      expect {
        described_class.new.call
      }.not_to change { LeadPartner.count }

      expect(LeadPartner.where(school_id: lead_school_1.id).count).to eq(1)
    end
  end
end