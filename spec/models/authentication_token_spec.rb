# frozen_string_literal: true

require "rails_helper"

RSpec.describe AuthenticationToken do
  let(:provider) { create(:provider) }

  describe ".create_with_random_token" do
    let(:token) { "Bearer #{described_class.create_with_random_token(provider_id: provider.id, name: 'Provider test token')}" }

    subject(:authentication_token) { AuthenticationToken.authenticate(token) }

    it "creates a new AuthenticationToken" do
      expect(authentication_token).to be_persisted
    end

    it "sets the hashed_token" do
      expect(authentication_token.hashed_token).not_to be_nil
    end

    it "sets the provider_id" do
      expect(authentication_token.provider_id).to eq(provider.id)
    end

    it "includes the environment name in the token" do
      expect(token.split.last.split("_").first).to eq("test")
    end

    it { is_expected.to validate_uniqueness_of(:hashed_token) }

    it { is_expected.to belong_to(:provider) }

    it { is_expected.to belong_to(:created_by).optional }

    it { is_expected.to belong_to(:revoked_by).optional }

    it { is_expected.to validate_length_of(:name).is_at_most(200) }
  end

  describe ".revoke" do
    let(:revoking_user) { provider.users.first }

    subject(:authentication_token) { described_class.create(provider_id: provider.id, name: "Provider test token") }

    before { subject.revoke(user: revoking_user) }

    it "revokes the token" do
      expect(subject.revoked?).to be(true)
    end

    it "associates the user who revoked the token" do
      expect(subject.revoked_by).to eq(revoking_user)
    end

    it "adds the revocation date for the token" do
      expect(subject.revoked_at).not_to be_nil
    end
  end
end
