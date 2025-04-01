# frozen_string_literal: true

require "rails_helper"

describe ".update_last_used_at_on_token!" do
  let(:token) { "auth_token" }
  let!(:auth_token) { create(:authentication_token, hashed_token: AuthenticationToken.hash_token(token), last_used_at: 1.week.ago, status: status) }

  context "for an active token" do
    let(:status) { "active" }

    it "calls update_last_used_at! on the auth_token" do
      get "/api/v0.1/info", headers: { Authorization: token } do
        expect(auth_token).to receive(:update_last_used_at!)
      end
    end

    it "causes the token to update last_used_at attribute" do
      get "/api/v0.1/info", headers: { Authorization: token }

      auth_token.reload

      expect(auth_token.last_used_at.today?).to be(true)
    end
  end

  context "for an revoked token" do
    let(:status) { "revoked" }

    it "doesn't call update_last_used_at! on the auth_token" do
      get "/api/v0.1/info", headers: { Authorization: token } do
        expect(auth_token).not_to receive(:update_last_used_at!)
      end
    end

    it "doesn't cause the token to update last_used_at attribute" do
      get "/api/v0.1/info", headers: { Authorization: token }

      auth_token.reload

      expect(auth_token.last_used_at.today?).to be(false)
    end
  end
end
