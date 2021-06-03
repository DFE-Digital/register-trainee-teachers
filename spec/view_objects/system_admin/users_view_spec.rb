# frozen_string_literal: true

require "rails_helper"

describe SystemAdmin::UsersView do
  let(:provider) { create(:provider) }
  let(:dttp_user) { create(:dttp_user, provider_dttp_id: provider.dttp_id) }
  let(:user) { create(:user, provider: provider) }

  subject { described_class.new(provider) }

  before do
    dttp_user
    user
  end

  describe "#registered" do
    it "returns users registered to the provider" do
      expect(subject.registered.count).to eq 1
      expect(subject.registered.first).to eq user
    end
  end

  describe "#not_registered" do
    it "returns dttp_users registered to the provider" do
      expect(subject.not_registered.count).to eq 1
      expect(subject.not_registered.first).to eq dttp_user
    end

    context "user with nil email" do
      before do
        dttp_user.update(email: nil)
      end

      it "does not return them" do
        expect(subject.not_registered).not_to include(dttp_user)
      end
    end
  end
end
