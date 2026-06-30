# frozen_string_literal: true

require "rails_helper"

RSpec.describe RestoreProvidersAccreditationService do
  describe "#call" do
    let!(:provider) { create(:provider, :unaccredited, name: "Shotton Hall SCITT", accreditation_id: "5999") }
    let!(:user) { create(:user) }
    let(:name) { "North East SCITT" }
    let(:accreditation_id) { "5609" }

    before do
      provider.users << user
    end

    it "sets accredited to true and updates name and accreditation_id" do
      described_class.call(provider:, name:, accreditation_id:)

      provider.reload
      expect(provider.accredited).to be true
      expect(provider.name).to eq(name)
      expect(provider.accreditation_id).to eq(accreditation_id)
    end

    it "discards a linked training partner when present" do
      training_partner = create(:training_partner, :scitt, provider: provider, ukprn: provider.ukprn)

      described_class.call(provider:, name:, accreditation_id:)

      expect(training_partner.reload).to be_discarded
    end

    it "preserves provider users" do
      expect {
        described_class.call(provider:, name:, accreditation_id:)
      }.not_to change { provider.reload.users.count }

      expect(provider.users).to include(user)
    end
  end
end
