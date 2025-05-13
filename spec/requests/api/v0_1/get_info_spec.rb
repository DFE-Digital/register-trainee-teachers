# frozen_string_literal: true

require "rails_helper"

describe "`GET /info` endpoint" do
  let(:token) { "info_token" }
  let!(:auth_token) { create(:authentication_token, hashed_token: AuthenticationToken.hash_token(token)) }

  before do
    get "/api/#{version}/info", headers: { Authorization: token }
  end

  context "using version v0.1" do
    let(:version) { "v0.1" }

    it_behaves_like "a register API endpoint", "/api/v0.1/info", "info_token"

    it "shows the requested version" do
      expect(response.parsed_body).to eq({ "status" => "ok", "version" => { "latest" => "v2025.0-rc", "requested" => "v0.1" } })
    end
  end
end
