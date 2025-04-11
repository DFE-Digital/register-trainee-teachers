# frozen_string_literal: true

require "rails_helper"

describe ProviderUser do
  describe "scopes" do
    describe ".with_active_hei_providers" do
      let(:active_hei_provider_user) { create(:provider_user, provider: build(:provider, :hei)) }
      let(:inactive_hei_provider_user) { create(:provider_user, provider: build(:provider, :hei)) }
      let(:unaccredited_hei_provider_user) { create(:provider_user, provider: build(:provider, :hei, :unaccredited)) }
      let(:active_scitt_provider_user) { create(:provider_user, provider: build(:provider, :scitt)) }
      let(:inactive_scitt_provider_user) { create(:provider_user, provider: build(:provider, :scitt)) }
      let(:unaccredited_scitt_provider_user) { create(:provider_user, provider: build(:provider, :scitt, :unaccredited)) }

      before do
        inactive_hei_provider_user.provider.discard
        inactive_scitt_provider_user.provider.discard

        active_hei_provider_user
        inactive_hei_provider_user
        unaccredited_hei_provider_user
        active_scitt_provider_user
        inactive_scitt_provider_user
        unaccredited_scitt_provider_user
      end

      it "returns provider user that have providers that are accredited and have a valid accreditation_id" do
        expect(described_class.with_active_hei_providers).to contain_exactly(active_hei_provider_user)
      end
    end
  end

  subject { create(:provider_user) }

  describe "validations" do
    it { is_expected.to validate_uniqueness_of(:user).scoped_to(:provider_id) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:provider) }
    it { is_expected.to belong_to(:user) }
  end
end
