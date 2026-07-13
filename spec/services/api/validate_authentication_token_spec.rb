# frozen_string_literal: true

require "rails_helper"

describe Api::ValidateAuthenticationToken do
  let(:auth_token) { create(:authentication_token) }

  describe "#call" do
    context "when the auth_token is active and the provider is present" do
      it "returns true" do
        expect(described_class.call(auth_token:)).to be(true)
      end
    end

    context "when the auth_token is active but the expiry date is in the past" do
      let(:auth_token) { create(:authentication_token, expires_at: 1.day.ago) }

      it "returns false" do
        expect(described_class.call(auth_token:)).to be(false)
      end
    end

    context "when the auth_token is active but the expiry date is today" do
      let(:auth_token) { create(:authentication_token, expires_at: Date.current) }

      it "returns false" do
        expect(described_class.call(auth_token:)).to be(false)
      end
    end

    context "when the auth_token is revoked and the provider is present" do
      let(:auth_token) { create(:authentication_token, :revoked) }

      it "returns false" do
        expect(described_class.call(auth_token:)).to be(false)
      end
    end

    context "when the auth_token is active and the provider is discarded" do
      before { auth_token.provider.discard }

      it "returns false" do
        expect(described_class.call(auth_token:)).to be(false)
      end
    end
  end
end
