# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe User do
    subject { build(:dttp_user) }

    it { is_expected.to be_valid }

    context "class methods" do
      describe ".not_registered_with_provider" do
        let(:provider) { build(:provider) }
        subject { create(:dttp_user, provider_dttp_id: provider.dttp_id) }

        before do
          create(:dttp_user)
        end

        it "returns the correct dttp_user for the given provider" do
          dttp_users = described_class.not_registered_with_provider(provider.dttp_id, provider.users.pluck(:dttp_id))

          expect(dttp_users).to include(subject)
          expect(dttp_users.count).to eq(1)
        end
      end
    end
  end
end
